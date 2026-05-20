import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../error/failures.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';

// Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  late final Dio _dio;
  late final Dio _refreshDio;
  final LocalStorage _storage = LocalStorage();

  ApiService() {
    _dio = _createDioInstance();
    _refreshDio = _createDioInstance();
  }

  // ─────────────────────────────────────────────
  // DIO SETUP
  // ─────────────────────────────────────────────

  Dio _createDioInstance() {
    final String baseUrl = AppConstants.baseUrl;
    final String normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    return Dio(
      BaseOptions(
        baseUrl: normalizedBase,
        connectTimeout: Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(seconds: AppConstants.receiveTimeout),
        validateStatus: (_) => true,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOKEN MANAGEMENT
  // ─────────────────────────────────────────────

  String? getToken() => _storage.getToken();

  void setToken(String token) => _storage.saveToken(token);

  // ─────────────────────────────────────────────
  // HEADERS
  // ─────────────────────────────────────────────

  Map<String, String> _prepareHeaders({bool isJson = false}) {
    final String platform = Platform.isIOS ? 'ios' : 'android';

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer ${getToken() ?? ''}',
      'X-Platform': platform,
      if (isJson) 'Content-Type': 'application/json',
    };
  }

  // ─────────────────────────────────────────────
  // PATH SANITIZATION
  // ─────────────────────────────────────────────

  String _sanitizePath(String path) =>
      path.startsWith('/') ? path.substring(1) : path;

  // ─────────────────────────────────────────────
  // RETRY CONFIGURATION
  // ─────────────────────────────────────────────

  static const int _retryLimit = 2;
  static const Duration _retryInterval = Duration(seconds: 1);

  Future<Response<dynamic>> _executeWithRetry(
    Future<Response<dynamic>> Function() request,
    String method,
    String path,
  ) async {
    int attempt = 0;

    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        final bool isTransient =
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;

        if (!isTransient) rethrow;

        attempt++;
        if (attempt > _retryLimit) rethrow;

        appLogger.w(
          'RETRY [$method] $path '
          '(attempt $attempt/$_retryLimit) — ${e.message}',
        );

        await Future<void>.delayed(_retryInterval * attempt);
      }
    }
  }

  // ─────────────────────────────────────────────
  // TOKEN REFRESH
  // ─────────────────────────────────────────────

  static Completer<bool>? _tokenRefreshLock;

  Future<bool> refreshToken() async {
    if (_tokenRefreshLock != null) {
      return _tokenRefreshLock!.future;
    }

    _tokenRefreshLock = Completer<bool>();

    try {
      final bool success = await _refreshAccessToken();
      _tokenRefreshLock!.complete(success);
      return success;
    } catch (e) {
      _tokenRefreshLock!.complete(false);
      return false;
    } finally {
      _tokenRefreshLock = null;
    }
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final currentToken = getToken();
      if (currentToken == null || currentToken.isEmpty) {
        return false;
      }

      final Response<dynamic> response = await _refreshDio.post<dynamic>(
        'auth/refresh',
        options: Options(
          headers: <String, String>{
            'Accept': 'application/json',
            'Authorization': 'Bearer $currentToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        final String? newToken =
            data is Map<String, dynamic>
                ? (data['access_token'] as String? ?? data['token'] as String?)
                : null;

        if (newToken != null && newToken.isNotEmpty) {
          setToken(newToken);
          appLogger.i('TOKEN REFRESH: Success');
          return true;
        }
      }

      return false;
    } catch (e) {
      appLogger.e('TOKEN REFRESH: Error — $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // ERROR HANDLING
  // ─────────────────────────────────────────────

  Never _handleErrorResponse(
    Response<dynamic> response,
    String method,
    String path,
  ) {
    final int? statusCode = response.statusCode;

    appLogger.e('$method $path → Error $statusCode');

    if (statusCode == 401) {
      throw const UnauthorizedFailure(
        message: 'Session expired. Please login again.',
      );
    }

    if (statusCode == 422) {
      final json =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : null;
      throw ServerFailure(
        message: json?['message'] as String? ?? 'Validation error',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      throw ServerFailure(
        message: 'Server error ($statusCode). Please try again.',
      );
    }

    final json =
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;
    throw ServerFailure(
      message:
          json?['message'] as String? ??
          json?['error'] as String? ??
          'Request failed ($statusCode)',
    );
  }

  // ─────────────────────────────────────────────
  // 401 HANDLER
  // ─────────────────────────────────────────────

  Future<Response<dynamic>> _handleUnauthorized(
    String method,
    String path,
    Future<Response<dynamic>> Function() retryRequest,
  ) async {
    final bool refreshed = await refreshToken();

    if (!refreshed) {
      throw const UnauthorizedFailure(
        message: 'Session expired. Please login again.',
      );
    }

    final Response<dynamic> retryResponse = await retryRequest();

    if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
      return retryResponse;
    }

    if (retryResponse.statusCode == 401) {
      throw const UnauthorizedFailure(
        message: 'Session expired. Please login again.',
      );
    }

    _handleErrorResponse(retryResponse, method, path);
  }

  // ─────────────────────────────────────────────
  // PUBLIC API METHODS
  // ─────────────────────────────────────────────

  // ── GET ───────────────────────────────────────

  Future<dynamic> get(String path) async {
    final String cleanPath = _sanitizePath(path);

    try {
      final Response<dynamic> response = await _executeWithRetry(
        () => _dio.get<dynamic>(
          cleanPath,
          options: Options(headers: _prepareHeaders()),
        ),
        'GET',
        cleanPath,
      );

      appLogger.d('GET $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200) return response.data;

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'GET',
          cleanPath,
          () => _dio.get<dynamic>(
            cleanPath,
            options: Options(headers: _prepareHeaders()),
          ),
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'GET', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }

  // ── POST ──────────────────────────────────────

  Future<dynamic> post(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) async {
    final String cleanPath = _sanitizePath(path);

    try {
      final Response<dynamic> response = await _executeWithRetry(
        () => _dio.post<dynamic>(
          cleanPath,
          data: body,
          options: Options(headers: _prepareHeaders(isJson: true)),
        ),
        'POST',
        cleanPath,
      );

      appLogger.d('POST $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'POST',
          cleanPath,
          () => _dio.post<dynamic>(
            cleanPath,
            data: body,
            options: Options(headers: _prepareHeaders(isJson: true)),
          ),
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'POST', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }

  // ── PUT ───────────────────────────────────────

  Future<dynamic> put(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) async {
    final String cleanPath = _sanitizePath(path);

    try {
      final Response<dynamic> response = await _executeWithRetry(
        () => _dio.put<dynamic>(
          cleanPath,
          data: body,
          options: Options(headers: _prepareHeaders(isJson: true)),
        ),
        'PUT',
        cleanPath,
      );

      appLogger.d('PUT $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'PUT',
          cleanPath,
          () => _dio.put<dynamic>(
            cleanPath,
            data: body,
            options: Options(headers: _prepareHeaders(isJson: true)),
          ),
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'PUT', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }

  // ── PATCH ─────────────────────────────────────

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) async {
    final String cleanPath = _sanitizePath(path);

    try {
      final Response<dynamic> response = await _executeWithRetry(
        () => _dio.patch<dynamic>(
          cleanPath,
          data: body,
          options: Options(headers: _prepareHeaders(isJson: true)),
        ),
        'PATCH',
        cleanPath,
      );

      appLogger.d('PATCH $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'PATCH',
          cleanPath,
          () => _dio.patch<dynamic>(
            cleanPath,
            data: body,
            options: Options(headers: _prepareHeaders(isJson: true)),
          ),
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'PATCH', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }

  // ── DELETE ────────────────────────────────────

  Future<dynamic> delete(String path) async {
    final String cleanPath = _sanitizePath(path);

    try {
      final Response<dynamic> response = await _executeWithRetry(
        () => _dio.delete<dynamic>(
          cleanPath,
          options: Options(headers: _prepareHeaders()),
        ),
        'DELETE',
        cleanPath,
      );

      appLogger.d('DELETE $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'DELETE',
          cleanPath,
          () => _dio.delete<dynamic>(
            cleanPath,
            options: Options(headers: _prepareHeaders()),
          ),
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'DELETE', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }

  // ── MULTIPART (File Upload) ───────────────────

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const <String, String>{},
    String? fileField,
    String? filePath,
  }) async {
    final String cleanPath = _sanitizePath(path);

    Future<FormData> buildForm() async {
      final Map<String, dynamic> formMap = <String, dynamic>{...fields};
      if (fileField != null && filePath != null) {
        formMap[fileField] = await MultipartFile.fromFile(filePath);
      }
      return FormData.fromMap(formMap);
    }

    try {
      final Map<String, String> headers = Map<String, String>.from(
        _prepareHeaders(),
      )..remove('Content-Type');

      final Response<dynamic> response = await _executeWithRetry(
        () async => _dio.post<dynamic>(
          cleanPath,
          data: await buildForm(),
          options: Options(headers: headers),
        ),
        'MULTIPART',
        cleanPath,
      );

      appLogger.d('MULTIPART $cleanPath → ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      if (response.statusCode == 401) {
        final retry = await _handleUnauthorized(
          'MULTIPART',
          cleanPath,
          () async {
            final Map<String, String> retryHeaders = Map<String, String>.from(
              _prepareHeaders(),
            )..remove('Content-Type');

            return _dio.post<dynamic>(
              cleanPath,
              data: await buildForm(),
              options: Options(headers: retryHeaders),
            );
          },
        );
        return retry.data;
      }

      _handleErrorResponse(response, 'MULTIPART', cleanPath);
    } on DioException catch (e) {
      throw NetworkFailure(message: e.message ?? 'Network error occurred');
    }
  }
}

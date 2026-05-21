import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/auth_response_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRemoteDataSource(apiService: apiService);
});

class AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource({required ApiService apiService})
    : _apiService = apiService;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        'login',
        body: {'email': email, 'password': password},
      );

      if (response != null && response is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(response);
      }

      throw const ServerFailure(message: 'Invalid response from server');
    } on Failure {
      rethrow;
    } catch (e) {
      appLogger.e('Login error: $e');
      throw ServerFailure(message: 'Login failed: $e');
    }
  }
}

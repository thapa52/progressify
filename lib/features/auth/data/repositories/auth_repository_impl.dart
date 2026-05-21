import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localStorage: localStorage,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorage localStorage,
  }) : _remoteDataSource = remoteDataSource,
       _localStorage = localStorage;

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _localStorage.saveAuthResponse(response.toJson());
    await _localStorage.saveUser((response.user as UserModel).toJson());
    await _localStorage.saveAuth(true);
    await _localStorage.saveToken(response.token);

    appLogger.i('Login successful for: $email');

    return response;
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearAll();
    appLogger.i('Logout successful - local storage cleared');
  }

  @override
  bool isLoggedIn() {
    return _localStorage.getAuth();
  }
}

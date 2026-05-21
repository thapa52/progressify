import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authEntity,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final isLoggedIn = _authRepository.isLoggedIn();
    if (isLoggedIn) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final authEntity = await _authRepository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      );
    } on Failure catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      appLogger.e('Login failed: ${e.message}');
      AppSnackbar.error(e.message);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      appLogger.e('Login unexpected error: $e');
      AppSnackbar.error('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _authRepository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      appLogger.e('Logout error: $e');
    }
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(
    authProvider.select((value) => value.status == AuthStatus.authenticated),
  );
});

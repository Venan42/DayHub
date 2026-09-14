import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/error_mapper.dart';
import 'package:frontend/core/errors/failure.dart';

import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => checkAuthStatus());
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final token = await repository.getSavedToken();
      if (token == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      final user = await repository.getMe();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        failure: ErrorMapper.fromDioException(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        failure: const UnknownFailure('Erro inesperado na autenticação'),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        failure: ErrorMapper.fromDioException(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        failure: const UnknownFailure('Erro inesperado na autenticação'),
      );
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

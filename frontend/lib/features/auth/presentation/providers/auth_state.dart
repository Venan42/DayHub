import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final Failure? failure;

  const AuthState({this.status = AuthStatus.initial, this.user, this.failure});

  Map<String, String> get fieldErrors {
    final f = failure;
    if (f is ValidationFailure) return f.fieldErrors;
    return const {};
  }

  AuthState copyWith({AuthStatus? status, UserEntity? user, Failure? failure}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure,
    );
  }
}

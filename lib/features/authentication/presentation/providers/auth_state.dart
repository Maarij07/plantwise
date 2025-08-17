import '../../domain/entities/user.dart';

abstract class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
  const factory AuthState.passwordResetSent() = AuthStatePasswordResetSent;

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(User user) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
    required T Function() passwordResetSent,
  }) {
    if (this is AuthStateInitial) {
      return initial();
    } else if (this is AuthStateLoading) {
      return loading();
    } else if (this is AuthStateAuthenticated) {
      return authenticated((this as AuthStateAuthenticated).user);
    } else if (this is AuthStateUnauthenticated) {
      return unauthenticated();
    } else if (this is AuthStateError) {
      return error((this as AuthStateError).message);
    } else if (this is AuthStatePasswordResetSent) {
      return passwordResetSent();
    } else {
      throw Exception('Unknown AuthState: $this');
    }
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(User user)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    T Function()? passwordResetSent,
    required T Function() orElse,
  }) {
    if (this is AuthStateInitial && initial != null) {
      return initial();
    } else if (this is AuthStateLoading && loading != null) {
      return loading();
    } else if (this is AuthStateAuthenticated && authenticated != null) {
      return authenticated((this as AuthStateAuthenticated).user);
    } else if (this is AuthStateUnauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (this is AuthStateError && error != null) {
      return error((this as AuthStateError).message);
    } else if (this is AuthStatePasswordResetSent && passwordResetSent != null) {
      return passwordResetSent();
    } else {
      return orElse();
    }
  }
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateInitial && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateLoading && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthStateAuthenticated extends AuthState {
  final User user;

  const AuthStateAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateUnauthenticated && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStatePasswordResetSent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

import 'package:flutter/foundation.dart' show immutable;
import 'package:my_notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn({required this.user});
}

class AuthStateLoginFailure extends AuthState {
  final Exception error;

  const AuthStateLoginFailure({required this.error});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

class AuthStateLoggedOutFailure extends AuthState {
  final Exception error;

  const AuthStateLoggedOutFailure({required this.error});
}

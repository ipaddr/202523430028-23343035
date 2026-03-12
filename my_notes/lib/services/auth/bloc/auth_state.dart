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

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? error;
  const AuthStateLoggedOut(this.error);
}

class AuthStateLoggedOutFailure extends AuthState {
  final Exception error;

  const AuthStateLoggedOutFailure({required this.error});
}

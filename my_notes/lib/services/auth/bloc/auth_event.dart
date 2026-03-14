import 'package:flutter/foundation.dart' show immutable;

/// Base class for all authentication events dispatched to [AuthBloc].
///
/// Every concrete event is `const`-constructible so that identical events are
/// value-equal and can safely be added to the bloc multiple times without
/// inadvertently skipping a state update.
@immutable
abstract class AuthEvent {
  const AuthEvent();
}

/// Triggers provider initialisation and resolves the initial auth state.
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

/// Requests a sign-in with [email] and [password].
class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin({required this.email, required this.password});
}

/// Signs out the currently authenticated user.
class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

/// Re-sends the email-verification message to the current user.
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

/// Creates a new account with [email] and [password].
class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister({required this.email, required this.password});
}

/// Transitions the UI to the registration screen.
class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

/// Transitions the UI to the "forgot password" screen.
class AuthEventShouldResetPassword extends AuthEvent {
  const AuthEventShouldResetPassword();
}

/// Sends a password-reset link to [email].
class AuthEventResetPassword extends AuthEvent {
  final String email;
  const AuthEventResetPassword({required this.email});
}

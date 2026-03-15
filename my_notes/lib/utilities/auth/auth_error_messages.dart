import 'package:my_notes/services/auth/auth_exceptions.dart';

/// Returns a human-readable error message for a login failure [error].
///
/// Returns `null` when [error] is `null` (no error to display).
String? loginErrorMessage(Exception? error) {
  if (error == null) return null;
  if (error is UserNotFoundAuthException) {
    return 'No user found for that email.';
  }
  if (error is WrongPasswordAuthException) {
    return 'Wrong password provided for that user.';
  }
  if (error is InvalidEmailAuthException) {
    return 'The email address is not valid.';
  }
  return 'Authentication error occurred.';
}

/// Returns a human-readable error message for a registration failure
/// [exception].
///
/// Returns `null` when [exception] is `null` (no error to display).
String? registerErrorMessage(Exception? exception) {
  if (exception == null) return null;
  if (exception is WeakPasswordAuthException) {
    return 'The password provided is too weak.';
  }
  if (exception is EmailAlreadyInUseAuthException) {
    return 'The account already exists for that email.';
  }
  if (exception is InvalidEmailAuthException) {
    return 'The email address is invalid.';
  }
  return 'Failed to register. Please try again.';
}

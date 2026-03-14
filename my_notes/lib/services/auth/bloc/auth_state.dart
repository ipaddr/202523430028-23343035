import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:my_notes/services/auth/auth_user.dart';

/// Base class for all authentication states emitted by [AuthBloc].
///
/// Every state carries an [isLoading] flag that the UI uses to decide whether
/// to show a loading overlay, and an optional [loadingText] to customise the
/// overlay message.
@immutable
abstract class AuthState {
  /// Whether a long-running operation is in progress.
  final bool isLoading;

  /// Optional message shown inside the loading overlay.
  final String? loadingText;

  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });
}

/// Initial state before the auth provider has been initialised.
class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

/// State shown while the user is on the registration screen.
///
/// [exception] is non-null when a previous registration attempt failed.
class AuthStateRegistering extends AuthState {
  /// The exception from the most recent failed registration attempt.
  final Exception? exception;

  const AuthStateRegistering({this.exception, required super.isLoading});
}

/// State representing a successfully authenticated, email-verified user.
class AuthStateLoggedIn extends AuthState {
  /// The authenticated user's details.
  final AuthUser user;

  const AuthStateLoggedIn({required this.user, required super.isLoading});
}

/// State shown when the user has registered but has not yet verified their
/// email address.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

/// State representing an unauthenticated session (logged out).
///
/// [error] is non-null when a previous login attempt failed so that the UI
/// can display an appropriate error message.
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  /// The exception from the most recent failed login attempt, or `null`.
  final Exception? error;

  const AuthStateLoggedOut(
    this.error, {
    required super.isLoading,
    super.loadingText = null,
  });

  @override
  List<Object?> get props => [error, isLoading];
}

/// State shown when the user is on the "forgot password" screen.
///
/// [hasSentEmail] becomes `true` after the reset link has been dispatched
/// successfully.  [exception] is non-null when the most recent attempt
/// failed.
class AuthStateForgotPassword extends AuthState {
  /// The exception from the most recent failed reset attempt.
  final Exception? exception;

  /// Whether the password-reset email has been sent successfully.
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    this.exception,
    required super.isLoading,
    required this.hasSentEmail,
  });
}

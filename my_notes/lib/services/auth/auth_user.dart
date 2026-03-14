import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Immutable value object that represents an authenticated user.
///
/// The app's UI and business logic depend on [AuthUser] rather than on
/// Firebase's own [User] type, which keeps the presentation layer decoupled
/// from the authentication SDK (Dependency-Inversion Principle).
@immutable
class AuthUser {
  /// The unique identifier assigned to this user by the auth provider.
  final String id;

  /// The user's email address.
  final String email;

  /// Whether the user has clicked the verification link sent to [email].
  final bool isEmailVerified;

  /// Creates an [AuthUser] directly from its field values.
  ///
  /// Prefer [AuthUser.fromFirebase] when wrapping a Firebase [User].
  const AuthUser({
    required this.id,
    required this.isEmailVerified,
    required this.email,
  });

  /// Creates an [AuthUser] from a Firebase Auth [User] instance.
  ///
  /// Maps Firebase-specific fields to the app's own model so that the rest
  /// of the codebase remains independent of the Firebase SDK.
  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      id: user.uid,
      isEmailVerified: user.emailVerified,
      email: user.email!,
    );
  }
}

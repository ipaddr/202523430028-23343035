import 'package:my_notes/services/auth/auth_user.dart';

/// Contract that every authentication back-end must satisfy.
///
/// Depending on this abstraction rather than on a concrete implementation
/// (e.g. [FirebaseAuthProvider]) is the key Dependency-Inversion Principle
/// technique used throughout the app.  It also enables lightweight mock
/// providers to be injected during unit and widget tests.
abstract class AuthProvider {
  /// Initialises the underlying authentication SDK (e.g. Firebase).
  ///
  /// Must be called before any other method.
  Future<void> initialize();

  /// Returns the currently signed-in [AuthUser], or `null` if no user is
  /// authenticated.
  AuthUser? get currentUser;

  /// Creates a new account with [email] and [password].
  ///
  /// Throws an [AuthException] subtype on failure (see
  /// `auth_exceptions.dart`).
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  /// Signs in an existing user with [email] and [password].
  ///
  /// Throws an [AuthException] subtype on failure.
  Future<AuthUser> logIn({required String email, required String password});

  /// Signs out the currently authenticated user.
  ///
  /// Throws [UserNotLoggedInAuthException] if no user is signed in.
  Future<void> logOut();

  /// Sends an email-verification message to the current user's address.
  ///
  /// Throws [UserNotLoggedInAuthException] if no user is signed in.
  Future<void> sendEmailVerification();

  /// Sends a password-reset email to [email].
  ///
  /// Throws [UserNotFoundAuthException] if the address is unknown.
  Future<void> sendPasswordReset({required String email});

  /// Reloads the current user's profile from the authentication server.
  ///
  /// Useful for checking whether the user has verified their email address
  /// since the app was last active.
  ///
  /// Throws [UserNotLoggedInAuthException] if no user is signed in.
  Future<void> reloadUser();
}

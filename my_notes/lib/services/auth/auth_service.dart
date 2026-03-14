import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_user.dart';
import 'package:my_notes/services/auth/firebase_auth_provider.dart';

/// A thin façade over [AuthProvider] that adds convenient named constructors.
///
/// [AuthService] itself implements [AuthProvider] and forwards every call to
/// the wrapped [provider], so callers that depend on [AuthProvider] can
/// receive either a real [AuthService] or a mock without any code changes
/// (Open/Closed and Dependency-Inversion Principles).
class AuthService implements AuthProvider {
  /// The underlying provider to which all operations are delegated.
  final AuthProvider provider;

  /// Creates an [AuthService] that delegates to [provider].
  const AuthService(this.provider);

  /// Creates an [AuthService] backed by Firebase Authentication.
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> sendPasswordReset({required String email}) =>
      provider.sendPasswordReset(email: email);

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> reloadUser() => provider.reloadUser();
}

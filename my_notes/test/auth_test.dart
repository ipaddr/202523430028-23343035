import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('cannot log out if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('user should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('create user should delegate to logIn', () async {
      final badEmailUser = provider.createUser(
        email: 'test@example.com',
        password: 'password',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPasswordUser = provider.createUser(
        email: 'user@example.com',
        password: 'wrongpassword',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(
        email: 'user@example.com',
        password: 'password',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
      expect(user.email, 'user@example.com');
    });

    test('logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
      expect(user.email, 'user@example.com');
    });

    test('should be able to log out and log in again', () async {
      await provider.logOut();
      expect(provider.currentUser, null);
      final user = await provider.logIn(
        email: 'user@example.com',
        password: 'password',
      );
      expect(provider.currentUser, user);
      expect(user.email, 'user@example.com');
    });

    // tests for reloadUser()
    test('cannot reload when not initialized', () {
      final newProvider = MockAuthProvider();
      expect(
        () => newProvider.reloadUser(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('reload without a user throws', () async {
      final fresh = MockAuthProvider();
      await fresh.initialize();
      expect(
        fresh.reloadUser(),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
    });

    test(
      'reloading a logged-in user works and does not change state',
      () async {
        final another = MockAuthProvider();
        await another.initialize();
        final user = await another.logIn(
          email: 'user@example.com',
          password: 'password',
        );
        expect(another.currentUser, user);
        await another.reloadUser();
        // state is unchanged by our fake implementation
        expect(another.currentUser, user);
      },
    );
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() {
    return Future.delayed(const Duration(seconds: 1), () {
      _isInitialized = true;
    });
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'test@example.com') throw UserNotFoundAuthException();
    // throw when the *provided* password is wrong, not when it matches a hardcoded
    // value. All tests treat "password" as the correct credential.
    if (password != 'password') throw WrongPasswordAuthException();
    final user = AuthUser(isEmailVerified: false, email: email);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    return Future.value();
  }

  @override
  Future<void> reloadUser() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    // mimic a network delay as other methods do
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(isEmailVerified: true, email: user.email);
    _user = newUser;
    return Future.value();
  }
}

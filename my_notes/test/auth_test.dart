import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/auth_user.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/auth/bloc/auth_state.dart';

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
      // id should be non-empty (mock generates a simple string)
      expect(user.id, isNotEmpty);
    });

    test('logged in user should be able to get verified', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
      expect(user.email, 'user@example.com');
      expect(user.id, isNotEmpty);
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
      expect(user.id, isNotEmpty);
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

    test('sending password reset with unknown email throws', () async {
      final fresh = MockAuthProvider();
      await fresh.initialize();
      expect(
        () => fresh.sendPasswordReset(email: 'test@example.com'),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
    });

    test('sending password reset succeeds with valid email', () async {
      final fresh = MockAuthProvider();
      await fresh.initialize();
      // first log in a user to mimic registration state (not strictly needed)
      await fresh.logIn(email: 'user@example.com', password: 'password');
      await fresh.sendPasswordReset(email: 'user@example.com');
      // no exception means success
    });
  });

  // ── Exception type hierarchy ─────────────────────────────────────────────

  group('Auth exception types', () {
    test('UserNotFoundAuthException implements Exception', () {
      expect(UserNotFoundAuthException(), isA<Exception>());
    });

    test('WrongPasswordAuthException implements Exception', () {
      expect(WrongPasswordAuthException(), isA<Exception>());
    });

    test('WeakPasswordAuthException implements Exception', () {
      expect(WeakPasswordAuthException(), isA<Exception>());
    });

    test('EmailAlreadyInUseAuthException implements Exception', () {
      expect(EmailAlreadyInUseAuthException(), isA<Exception>());
    });

    test('InvalidEmailAuthException implements Exception', () {
      expect(InvalidEmailAuthException(), isA<Exception>());
    });

    test('GenericAuthException implements Exception', () {
      expect(GenericAuthException(), isA<Exception>());
    });

    test('UserNotLoggedInAuthException implements Exception', () {
      expect(UserNotLoggedInAuthException(), isA<Exception>());
    });
  });

  // ── AuthUser ─────────────────────────────────────────────────────────────

  group('AuthUser', () {
    test('stores id, email, and isEmailVerified correctly', () {
      const user = AuthUser(
        id: 'uid123',
        email: 'test@example.com',
        isEmailVerified: false,
      );
      expect(user.id, 'uid123');
      expect(user.email, 'test@example.com');
      expect(user.isEmailVerified, false);
    });

    test('can be created with isEmailVerified = true', () {
      const user = AuthUser(
        id: 'uid',
        email: 'a@b.com',
        isEmailVerified: true,
      );
      expect(user.isEmailVerified, true);
    });
  });

  // ── AuthBloc ─────────────────────────────────────────────────────────────

  group('AuthBloc forgot password flows', () {
    late AuthBloc bloc;
    late MockAuthProvider provider;

    setUp(() {
      provider = MockAuthProvider();
      bloc = AuthBloc(provider);
    });

    test('should navigate to forgot password state', () {
      expectLater(bloc.stream, emits(isA<AuthStateForgotPassword>()));
      bloc.add(const AuthEventShouldResetPassword());
    });

    test('reset password success sequence', () async {
      await provider.initialize();
      // prepare a user so provider doesn't throw on valid email
      await provider.logIn(email: 'user@example.com', password: 'password');
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthStateForgotPassword>(),
          isA<AuthStateForgotPassword>().having(
            (s) => s.isLoading,
            'loading',
            true,
          ),
          isA<AuthStateForgotPassword>().having(
            (s) => s.hasSentEmail,
            'sentEmail',
            true,
          ),
        ]),
      );
      bloc.add(const AuthEventShouldResetPassword());
      bloc.add(const AuthEventResetPassword(email: 'user@example.com'));
    });

    test('reset password failure emits exception', () async {
      await provider.initialize();
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthStateForgotPassword>(),
          isA<AuthStateForgotPassword>().having(
            (s) => s.isLoading,
            'loading',
            true,
          ),
          isA<AuthStateForgotPassword>().having(
            (s) => s.exception,
            'exception',
            isNotNull,
          ),
        ]),
      );
      bloc.add(const AuthEventShouldResetPassword());
      bloc.add(
        const AuthEventResetPassword(email: 'test@example.com'),
      ); // will throw
    });
  });

  group('AuthBloc registration flow', () {
    late AuthBloc bloc;
    late MockAuthProvider provider;

    setUp(() {
      provider = MockAuthProvider();
      bloc = AuthBloc(provider);
    });

    test('AuthEventShouldRegister transitions to AuthStateRegistering', () {
      expectLater(bloc.stream, emits(isA<AuthStateRegistering>()));
      bloc.add(const AuthEventShouldRegister());
    });

    test('successful registration transitions to AuthStateNeedsVerification',
        () async {
      await provider.initialize();
      expectLater(
        bloc.stream,
        emitsThrough(isA<AuthStateNeedsVerification>()),
      );
      bloc.add(
        const AuthEventRegister(
          email: 'user@example.com',
          password: 'password',
        ),
      );
    });

    test('failed registration emits AuthStateRegistering with exception',
        () async {
      await provider.initialize();
      expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthStateRegistering>().having(
            (s) => s.exception,
            'exception',
            isNotNull,
          ),
        ),
      );
      bloc.add(
        const AuthEventRegister(
          email: 'test@example.com', // triggers UserNotFoundAuthException
          password: 'password',
        ),
      );
    });
  });

  group('AuthBloc login flow', () {
    late AuthBloc bloc;
    late MockAuthProvider provider;

    setUp(() {
      provider = MockAuthProvider();
      bloc = AuthBloc(provider);
    });

    test('login with uninitialized provider emits AuthStateLoggedOut with error',
        () {
      expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthStateLoggedOut>().having(
            (s) => s.error,
            'error',
            isNotNull,
          ),
        ),
      );
      bloc.add(
        const AuthEventLogin(email: 'any@any.com', password: 'pass'),
      );
    });
  });
}

// ── Test doubles ─────────────────────────────────────────────────────────────

/// Sentinel exception thrown by [MockAuthProvider] when a method is called
/// before [MockAuthProvider.initialize].
class NotInitializedException implements Exception {}

/// In-memory [AuthProvider] used in unit tests.
///
/// All credentials are hardcoded:
/// - Any email other than `test@example.com` with the password `password`
///   will succeed.
/// - `test@example.com` always triggers [UserNotFoundAuthException].
/// - Any password other than `password` triggers [WrongPasswordAuthException].
class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  /// Whether [initialize] has been called on this provider.
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
    if (password != 'password') throw WrongPasswordAuthException();
    final generatedId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = AuthUser(
      id: generatedId,
      isEmailVerified: false,
      email: email,
    );
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
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> sendEmailVerification() {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(
      id: user.id,
      isEmailVerified: true,
      email: user.email,
    );
    _user = newUser;
    return Future.value();
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'test@example.com') throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    return Future.value();
  }
}

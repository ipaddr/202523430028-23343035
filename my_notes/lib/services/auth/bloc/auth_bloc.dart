import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/services/auth/auth_provider.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/auth/bloc/auth_state.dart';

/// BLoC that manages the authentication lifecycle of the application.
///
/// Accepts [AuthEvent]s and maps them to [AuthState]s by delegating the
/// actual auth operations to the injected [AuthProvider].  Because the bloc
/// only knows about the abstract [AuthProvider] interface, the concrete
/// implementation (Firebase, mock, etc.) can be swapped without modifying
/// this class — satisfying both the Open/Closed and Dependency-Inversion
/// Principles.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc] backed by the given [provider].
  AuthBloc(AuthProvider provider)
    : super(const AuthStateUninitialized(isLoading: false)) {
    // ── Email verification ─────────────────────────────────────────────────
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    // ── Registration ───────────────────────────────────────────────────────
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    // ── Initialisation ─────────────────────────────────────────────────────
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // ── Navigate to registration screen ────────────────────────────────────
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(isLoading: false));
    });

    // ── Navigate to forgot-password screen ─────────────────────────────────
    on<AuthEventShouldResetPassword>((event, emit) {
      emit(
        const AuthStateForgotPassword(isLoading: false, hasSentEmail: false),
      );
    });

    // ── Send password-reset email ──────────────────────────────────────────
    on<AuthEventResetPassword>((event, emit) async {
      final email = event.email;
      emit(const AuthStateForgotPassword(isLoading: true, hasSentEmail: false));
      try {
        await provider.sendPasswordReset(email: email);
        emit(
          const AuthStateForgotPassword(isLoading: false, hasSentEmail: true),
        );
      } on Exception catch (e) {
        emit(
          AuthStateForgotPassword(
            isLoading: false,
            hasSentEmail: false,
            exception: e,
          ),
        );
      }
    });

    // ── Login ──────────────────────────────────────────────────────────────
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(null, isLoading: true));
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e, isLoading: false));
      }
    });

    // ── Logout ─────────────────────────────────────────────────────────────
    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e, isLoading: false));
      }
    });
  }
}

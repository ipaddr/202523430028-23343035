import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/helpers/loading/loading_screen.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/auth/bloc/auth_state.dart';
import 'package:my_notes/services/auth/firebase_auth_provider.dart';
import 'package:my_notes/views/email_verify_view.dart';
import 'package:my_notes/views/forgot_password_view.dart';
import 'package:my_notes/views/login_view.dart';
import 'package:my_notes/views/notes/create_update_note_view.dart';
import 'package:my_notes/views/notes/notes_view.dart';
import 'package:my_notes/views/register_view.dart';
import 'package:my_notes/views/splash_view.dart';

/// Entry point of the application.
///
/// Initialises Flutter bindings before running the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

/// Root widget that configures global theming and injects [AuthBloc] at the
/// top of the widget tree.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        primaryColor: const Color(0xFF004643), // Cyprus
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Cloud White
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004643),
          foregroundColor: Colors.white,
        ),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoutes: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

/// Root home widget that listens to [AuthBloc] and routes the user to the
/// appropriate screen based on the current [AuthState].
///
/// Also manages the global loading overlay: it is shown whenever
/// [AuthState.isLoading] is `true` and hidden otherwise.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateUninitialized) {
          return const SplashView();
        } else if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const EmailVerifyView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

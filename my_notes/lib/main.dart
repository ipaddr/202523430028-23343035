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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        // custom colors
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEventInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // show or hide the loading overlay based on the state's flag
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
          // fallback while loading/unknown
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

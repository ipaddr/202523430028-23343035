import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/views/email_verify_view.dart';
import 'package:my_notes/views/login_view.dart';
import 'package:my_notes/views/notes_view.dart';
import 'package:my_notes/views/register_view.dart';

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
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      routes: {
        notesRoutes: (context) => const NotesView(),
        loginRoutes: (context) => const LoginView(),
        registerRoutes: (context) => const RegisterView(),
        verifyEmailRoutes: (context) => const EmailVerifyView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // saat Firebase sudah siap, lakukan navigasi
          final user = AuthService.firebase().currentUser;
          if (user != null) {
            if (user.isEmailVerified) {
              return const NotesView();
            } else {
              return const EmailVerifyView();
            }
          } else {
            return const LoginView();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

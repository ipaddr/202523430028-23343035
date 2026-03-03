import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // successful login → re-run NotesView logic
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(notesRoutes, (route) => false);
                } on FirebaseAuthException catch (e) {
                  String errorMessage;
                  switch (e.code) {
                    case 'invalid-credential':
                      errorMessage =
                          'Invalid email or password. (code: ${e.code})';
                      break;
                    case 'user-not-found':
                      errorMessage =
                          'No account found for this email. (code: ${e.code})';
                      break;
                    case 'invalid-email':
                      errorMessage =
                          'Email address is not valid. (code: ${e.code})';
                      break;
                    default:
                      errorMessage =
                          'Login failed: ${e.message} (code: ${e.code})';
                  }

                  if (!context.mounted) return;
                  await showErrorDialog(context, errorMessage);
                } catch (e) {
                  if (!context.mounted) return;
                  await showErrorDialog(
                    context,
                    'An unexpected error occurred: $e',
                  );
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(registerRoutes, (route) => false);
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

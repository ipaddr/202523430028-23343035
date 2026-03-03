import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              controller: emailController,
            ),
            const SizedBox(height: 16),
            // Password field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                // Basic validation
                if (email.isEmpty || password.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter email and password'),
                    ),
                  );
                  return;
                } else if (password.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password must be at least 6 characters long',
                      ),
                    ),
                  );
                  return;
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && !user.emailVerified) {
                    await user.sendEmailVerification();
                  }

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Registration successful!')),
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoutes,
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  String errorMessage;
                  switch (e.code) {
                    case 'email-already-in-use':
                      errorMessage =
                          'This email is already in use. (code: ${e.code})';
                      break;
                    case 'invalid-email':
                      errorMessage =
                          'The email address is not valid. (code: ${e.code})';
                      break;
                    case 'operation-not-allowed':
                      errorMessage =
                          'Email/password accounts are not enabled. (code: ${e.code})';
                      break;
                    case 'weak-password':
                      errorMessage =
                          'The password is too weak. Please choose a stronger password. (code: ${e.code})';
                      break;
                    default:
                      errorMessage =
                          'Registration failed: ${e.message} (code: ${e.code})';
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
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(loginRoutes, (route) => false);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

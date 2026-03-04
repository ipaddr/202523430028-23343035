import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_service.dart';
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
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );

                  final user = AuthService.firebase().currentUser;
                  if (user != null && !user.isEmailVerified) {
                    await AuthService.firebase().sendEmailVerification();
                  }

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Registration successful!')),
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoutes,
                    (route) => false,
                  );
                } on WeakPasswordAuthException {
                  await showErrorDialog(context, 'Weak Password');
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(context, 'Email is already in use');
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, 'Invalid email address');
                } on GenericAuthException {
                  await showErrorDialog(context, 'Failed to register');
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Registration successful!')),
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('This email is already in use.'),
                      ),
                    );
                  } else if (e.code == 'invalid-email') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('The email address is not valid.'),
                      ),
                    );
                  } else if (e.code == 'operation-not-allowed') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Email/password accounts are not enabled.',
                        ),
                      ),
                    );
                  } else if (e.code == 'weak-password') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('The password is too weak.'),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Registration failed: ${e.message}'),
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'An unexpected error occurred. Please try again.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

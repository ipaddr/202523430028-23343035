import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerifyView extends StatefulWidget {
  const EmailVerifyView({super.key});

  @override
  State<EmailVerifyView> createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                const Text('Please verify your email address.'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    final messenger = ScaffoldMessenger.of(context);
                    if (user == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('No authenticated user found.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await user.sendEmailVerification();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent.'),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.message ?? 'Failed to send verification email.',
                          ),
                        ),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to send verification email.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Send Verification Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    final messenger = ScaffoldMessenger.of(context);
                    if (user == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('No authenticated user found.'),
                        ),
                      );
                      return;
                    }
                    try {
                      await user.reload();
                      final refreshedUser = FirebaseAuth.instance.currentUser;
                      if (refreshedUser != null &&
                          refreshedUser.emailVerified == true) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Email verified successfully.'),
                          ),
                        );
                        // navigate back to home; HomePage will now show NotesView
                        if (!context.mounted) return;
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your email is not verified yet. Please check your inbox.',
                            ),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.message ??
                                'Failed to check verification status. Please try again.',
                          ),
                        ),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to check verification status. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('I have verified my email'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';

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
                const Text(
                  'We have sent you a verification email. Please check your inbox and verify your email address.',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final user = AuthService.firebase().currentUser;
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
                      await AuthService.firebase().sendEmailVerification();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Verification email sent.'),
                        ),
                      );
                    } on GenericAuthException {
                      if (!context.mounted) return;
                      await showErrorDialog(
                        context,
                        'Failed to send verification email. Please try again later.',
                      );
                    }
                  },
                  child: const Text('Resend Verification Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final user = AuthService.firebase().currentUser;
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
                      // refresh the user through the auth service
                      await AuthService.firebase().reloadUser();
                      final refreshedUser = AuthService.firebase().currentUser;
                      if (refreshedUser != null &&
                          refreshedUser.isEmailVerified) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Email verified successfully.'),
                          ),
                        );
                        // navigate back to home; HomePage will now show NotesView
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoutes,
                          (route) => false,
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your email is not verified yet. Please check your inbox.',
                            ),
                          ),
                        );
                      }
                    } on GenericAuthException {
                      if (!context.mounted) return;
                      await showErrorDialog(
                        context,
                        'Failed to check verification status. Please try again later.',
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      await showErrorDialog(
                        context,
                        'An unexpected error occurred. Please try again later.',
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

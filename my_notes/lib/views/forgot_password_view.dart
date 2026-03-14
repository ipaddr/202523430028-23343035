import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/auth/bloc/auth_state.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

/// Screen that lets a user request a password-reset email.
///
/// Listens to [AuthBloc] for [AuthStateForgotPassword] states:
/// - When [AuthStateForgotPassword.exception] is non-null an error dialog is
///   shown.
/// - When [AuthStateForgotPassword.hasSentEmail] is `true` a success dialog
///   is shown and the user is then sent back to the login screen.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.exception != null) {
            if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(context, 'No user found for that email.');
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(context, 'The email address is not valid.');
            } else {
              await showErrorDialog(
                context,
                'Error sending password reset email.',
              );
            }
          } else if (state.hasSentEmail) {
            // Capture the bloc reference before the async gap so that we
            // never call context.read after the widget might have unmounted.
            final authBloc = context.read<AuthBloc>();
            await showGenericDialog<bool>(
              context: context,
              title: 'Check your inbox',
              content: 'We sent a password reset link to your email address.',
              optionsBuilder: () => {'OK': true},
            );
            if (!mounted) return;
            authBloc.add(const AuthEventLogout());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reset password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  context.read<AuthBloc>().add(
                    AuthEventResetPassword(email: email),
                  );
                },
                child: const Text('Send reset link'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

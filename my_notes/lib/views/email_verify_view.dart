import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';

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
                    context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
                  },
                  child: const Text('Resend Verification Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventLogout());
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

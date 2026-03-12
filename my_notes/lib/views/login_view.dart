import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/bloc/auth_bloc.dart';
import 'package:my_notes/services/auth/bloc/auth_event.dart';
import 'package:my_notes/services/auth/bloc/auth_state.dart';
import 'package:my_notes/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.error is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              'The password provided is too weak.',
            );
          } else if (state.error is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              'The account already exists for that email.',
            );
          } else if (state.error is InvalidEmailAuthException) {
            await showErrorDialog(context, 'The email address is not valid.');
          } else if (state.error is UserNotFoundAuthException) {
            await showErrorDialog(context, 'No user found for that email.');
          } else if (state.error is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              'Wrong password provided for that user.',
            );
          } else if (state.error is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error occurred.');
          }
        }
      },
      child: Scaffold(
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
                  context.read<AuthBloc>().add(
                    AuthEventLogin(email: email, password: password),
                  );
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventShouldResetPassword(),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

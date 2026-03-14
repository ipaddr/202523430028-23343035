import 'package:flutter/material.dart';

/// Splash / launch screen shown while the auth state is being resolved.
///
/// Displays the app icon and the application name in the centre of the screen.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/icon.png', width: 100, height: 100),
            const SizedBox(height: 16),
            const Text(
              'My Notes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;

  const AuthUser({required this.isEmailVerified, this.email});

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(isEmailVerified: user.emailVerified, email: user.email);
  }
}

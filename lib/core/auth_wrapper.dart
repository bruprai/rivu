// lib/core/auth_wrapper.dart - Auth Check + Routing
import 'package:extra/auth_provider.dart';
import 'package:extra/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authProvider.user != null
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}

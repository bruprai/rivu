// lib/screens/email_verification_screen.dart
import 'package:rivu/auth_provider.dart';
import 'package:rivu/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Check your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('We sent a verification link to your inbox'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthProvider>().resendVerification(),
              child: const Text('Resend Email'),
            ),
            TextButton(
              onPressed: () => context.read<AuthProvider>().signOut(),
              child: const Text('Use different email'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('ClinicalPilot', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Sign in to continue', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              // TODO: Replace with real email/password fields + Supabase auth
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue as Demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

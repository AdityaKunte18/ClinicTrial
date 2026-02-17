import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // ── Avatar ──────────────────────────────
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      _initials(user.name),
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: theme.textTheme.titleLarge),
                  Text(
                    _roleLabel(user.role.name),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),

                  // ── Info Card ───────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          _infoRow(context, Icons.email_outlined, 'Email',
                              user.email),
                          const Divider(height: 24),
                          _infoRow(context, Icons.phone_outlined, 'Phone',
                              user.phone ?? '---'),
                          const Divider(height: 24),
                          _infoRow(context, Icons.badge_outlined, 'Role',
                              _roleLabel(user.role.name)),
                          const Divider(height: 24),
                          _infoRow(
                              context,
                              Icons.local_hospital_outlined,
                              'Unit',
                              user.unit ?? '---'),
                          const Divider(height: 24),
                          _infoRow(context, Icons.business_outlined,
                              'Hospital ID', user.hospitalId),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Sign Out ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(authProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'consultant':
        return 'Consultant';
      case 'jr3':
        return 'JR3 / Senior Resident';
      case 'jr2':
        return 'JR2 / Junior Resident';
      case 'jr1':
        return 'JR1 / Intern';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

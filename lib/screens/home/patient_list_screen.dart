import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import 'widgets/patient_card.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admissionsAsync = ref.watch(activeAdmissionsWithPatientsProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Patients'),
            if (authState.user != null)
              Text(
                authState.user!.name,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_information_outlined),
            tooltip: 'Syndrome Templates',
            onPressed: () => context.push('/settings/templates'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/reminders'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/settings/profile');
                  break;
                case 'templates':
                  context.push('/settings/templates');
                  break;
                case 'mjpjay':
                  context.push('/settings/mjpjay');
                  break;
                case 'logout':
                  ref.read(authProvider.notifier).signOut();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'profile', child: Text('Profile')),
              const PopupMenuItem(
                  value: 'templates', child: Text('Templates')),
              const PopupMenuItem(
                  value: 'mjpjay', child: Text('MJPJAY/PMJAY')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                  value: 'logout', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search patients by name or UHID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(patientSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                ref.read(patientSearchQueryProvider.notifier).state = v;
              },
            ),
          ),

          // ── Patient List ──────────────────────────────
          Expanded(
            child: admissionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text('Error loading patients',
                        style: theme.textTheme.titleMedium),
                    Text(err.toString(),
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(
                          activeAdmissionsWithPatientsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (admissions) {
                if (admissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No active admissions',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Tap + to admit a new patient',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(activeAdmissionsWithPatientsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: admissions.length,
                    itemBuilder: (context, index) {
                      return PatientCard(data: admissions[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admission'),
        icon: const Icon(Icons.add),
        label: const Text('Admit'),
      ),
    );
  }
}

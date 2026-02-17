import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/repository_providers.dart';

class MjpjayScreen extends ConsumerWidget {
  const MjpjayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dataRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('MJPJAY / PMJAY')),
      body: FutureBuilder(
        future: repo.getHospitals(),
        builder: (context, snapshot) {
          final hospital =
              snapshot.hasData && snapshot.data!.isNotEmpty
                  ? snapshot.data!.first
                  : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hospital Status Card ──────────────────
                if (hospital != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(hospital.name,
                                    style: theme.textTheme.titleMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(hospital.city,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              _empanelmentChip(
                                context,
                                'MJPJAY',
                                hospital.mjpjayEmpanelled,
                              ),
                              _empanelmentChip(
                                context,
                                'PMJAY',
                                hospital.pmjayEmpanelled,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── MJPJAY Info ───────────────────────────
                Card(
                  child: ExpansionTile(
                    leading: Icon(Icons.health_and_safety,
                        color: theme.colorScheme.primary),
                    title: const Text('MJPJAY'),
                    subtitle: const Text(
                        'Mahatma Jyotirao Phule Jan Arogya Yojana'),
                    initiallyExpanded: true,
                    children: const [
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoItem(
                              icon: Icons.location_on_outlined,
                              text: 'Maharashtra state health scheme',
                            ),
                            _InfoItem(
                              icon: Icons.people_outlined,
                              text:
                                  'Covers families with Orange & Yellow ration cards',
                            ),
                            _InfoItem(
                              icon: Icons.currency_rupee,
                              text:
                                  'Annual cover up to Rs 1.5 lakh per family',
                            ),
                            _InfoItem(
                              icon: Icons.medical_services_outlined,
                              text:
                                  'Covers 900+ procedures across 30 specialties',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── PMJAY Info ────────────────────────────
                Card(
                  child: ExpansionTile(
                    leading: Icon(Icons.shield_outlined,
                        color: theme.colorScheme.secondary),
                    title: const Text('PMJAY'),
                    subtitle: const Text(
                        'Pradhan Mantri Jan Arogya Yojana (Ayushman Bharat)'),
                    children: const [
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoItem(
                              icon: Icons.flag_outlined,
                              text: 'Central government scheme',
                            ),
                            _InfoItem(
                              icon: Icons.currency_rupee,
                              text:
                                  'Rs 5 lakh per family per year',
                            ),
                            _InfoItem(
                              icon: Icons.people_outlined,
                              text:
                                  'Covers SECC 2011 eligible families',
                            ),
                            _InfoItem(
                              icon: Icons.travel_explore,
                              text: 'Portable across India',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Eligibility Criteria ──────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.checklist_outlined,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Eligibility by Ration Card',
                                style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _rationCardRow(context, 'Yellow (BPL)',
                            'MJPJAY + PMJAY eligible', Colors.amber),
                        const Divider(height: 16),
                        _rationCardRow(
                            context,
                            'Orange (Antyodaya)',
                            'MJPJAY eligible',
                            Colors.orange),
                        const Divider(height: 16),
                        _rationCardRow(
                            context,
                            'White (APL)',
                            'Not eligible for MJPJAY',
                            Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _empanelmentChip(
      BuildContext context, String label, bool empanelled) {
    return Chip(
      avatar: Icon(
        empanelled ? Icons.check_circle : Icons.cancel_outlined,
        size: 18,
        color: empanelled ? Colors.green : Colors.grey,
      ),
      label: Text('$label ${empanelled ? "Empanelled" : "Not Empanelled"}'),
      backgroundColor: empanelled
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _rationCardRow(
      BuildContext context, String title, String subtitle, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium),
              Text(subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

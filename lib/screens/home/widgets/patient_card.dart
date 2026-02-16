import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/models.dart';
import '../../../providers/patient_providers.dart';
import '../../../providers/syndrome_providers.dart';

/// Displays an admission as a patient card with traffic light status indicator.
class PatientCard extends ConsumerWidget {
  final AdmissionWithPatient data;

  const PatientCard({super.key, required this.data});

  Color _dayColor(int day) {
    switch (day) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return day > 5 ? Colors.red.shade900 : Colors.grey;
    }
  }

  Color _statusColor(AdmissionStatus status) {
    switch (status) {
      case AdmissionStatus.active:
        return Colors.green;
      case AdmissionStatus.discharged:
        return Colors.blue;
      case AdmissionStatus.transferred:
        return Colors.orange;
      case AdmissionStatus.lama:
        return Colors.red;
      case AdmissionStatus.expired:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = data.patient;
    final admission = data.admission;
    final theme = Theme.of(context);

    // Resolve syndrome names
    final syndromeNames = <String>[];
    final synProtocols = ref.watch(syndromeProtocolsProvider);
    synProtocols.whenData((protocols) {
      final protocolMap = {for (final p in protocols) p.id: p};
      for (final as_ in data.syndromes) {
        final p = protocolMap[as_.syndromeId];
        if (p != null) {
          syndromeNames.add(as_.isPrimary ? '${p.name} (Primary)' : p.name);
        }
      }
    });

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/workup/${admission.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Name, Bed, Day indicator ──────
              Row(
                children: [
                  // Day badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _dayColor(admission.currentDay),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'D${admission.currentDay}',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + UHID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${patient.uhid} · ${patient.age}${patient.sex} · Bed ${admission.bedNumber ?? "—"}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(admission.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      admission.status.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _statusColor(admission.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Syndromes row ─────────────────────────
              if (syndromeNames.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: syndromeNames
                      .map((name) => Chip(
                            label: Text(name,
                                style: theme.textTheme.labelSmall),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),

              // ── Discharge block warning ───────────────
              if (admission.dischargeBlocked) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block,
                          size: 16, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Discharge blocked: ${admission.dischargeBlockReasons?.join(", ") ?? "Pending items"}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Scheme eligibility badges ─────────────
              if (patient.pmjayEligible || patient.mjpjayEligible) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (patient.pmjayEligible)
                      _schemeBadge(theme, 'PMJAY', Colors.green),
                    if (patient.pmjayEligible && patient.mjpjayEligible)
                      const SizedBox(width: 6),
                    if (patient.mjpjayEligible)
                      _schemeBadge(theme, 'MJPJAY', Colors.orange),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _schemeBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

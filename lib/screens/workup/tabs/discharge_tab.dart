import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../models/models.dart';
import '../../../providers/patient_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/workup_providers.dart';
import '../widgets/workup_helpers.dart';

/// Discharge tab content — hard blocks, soft warnings, and discharge button.
class DischargeTab extends ConsumerWidget {
  final String admissionId;
  const DischargeTab({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final checkAsync = ref.watch(dischargeCheckProvider(admissionId));

    return checkAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (check) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hard Blocks ─────────────────────────────
            _sectionHeader(
              context,
              Icons.block,
              'Hard Blocks',
              check.hardBlocks.length,
              theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
            if (check.hardBlocks.isEmpty)
              _resolvedBanner(context, theme)
            else
              ...check.hardBlocks
                  .map((item) => _blockCard(context, theme, item, true)),
            const SizedBox(height: 24),

            // ── Soft Warnings ───────────────────────────
            _sectionHeader(
              context,
              Icons.warning_amber,
              'Soft Warnings',
              check.softWarnings.length,
              AppTheme.warning,
            ),
            const SizedBox(height: 8),
            if (check.softWarnings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No warnings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              )
            else
              ...check.softWarnings
                  .map((item) => _blockCard(context, theme, item, false)),
            const SizedBox(height: 32),

            // ── Discharge Button ────────────────────────
            if (!check.canDischarge)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Resolve all hard blocks before discharge',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: check.canDischarge
                    ? () => _discharge(context, ref)
                    : null,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Discharge Patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title,
      int count, Color color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style:
                  theme.textTheme.labelMedium?.copyWith(color: color)),
        ),
      ],
    );
  }

  Widget _resolvedBanner(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.statusDone),
          const SizedBox(width: 12),
          Text('All hard blocks resolved',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.statusDone)),
        ],
      ),
    );
  }

  Widget _blockCard(
      BuildContext context, ThemeData theme, WorkupItem item, bool isHardBlock) {
    final color = isHardBlock ? theme.colorScheme.error : AppTheme.warning;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemText,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _domainChip(theme, item.domain),
                        const SizedBox(width: 6),
                        _statusChip(theme, item.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _domainChip(ThemeData theme, WorkupDomain domain) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        domain.name[0].toUpperCase() + domain.name.substring(1),
        style: theme.textTheme.labelSmall,
      ),
    );
  }

  Widget _statusChip(ThemeData theme, WorkupStatus status) {
    final color = WorkupHelpers.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  Future<void> _discharge(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(dataRepositoryProvider);
    final admission =
        await ref.read(admissionByIdProvider(admissionId).future);
    if (admission == null) return;

    await repo.updateAdmission(admission.copyWith(
      status: AdmissionStatus.discharged,
      actualDischargeDate: DateTime.now(),
      dischargeBlocked: false,
    ));

    ref.invalidate(activeAdmissionsProvider);
    ref.invalidate(activeAdmissionsWithPatientsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient discharged successfully')),
      );
      context.go('/');
    }
  }
}

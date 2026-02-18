import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/patient_providers.dart';
import '../../../providers/workup_providers.dart';
import '../widgets/workup_helpers.dart';

/// Overview tab — patient info card, day simulator, progress tracking.
class OverviewTab extends ConsumerWidget {
  final String admissionId;
  final TabController tabController;

  const OverviewTab({
    super.key,
    required this.admissionId,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final admissionAsync = ref.watch(admissionByIdProvider(admissionId));
    final progressAsync = ref.watch(workupProgressProvider(admissionId));
    final effectiveDayAsync = ref.watch(effectiveDayProvider(admissionId));
    final syndromeNamesAsync =
        ref.watch(admissionSyndromeNamesProvider(admissionId));

    // Resolve patient
    final patientId =
        admissionAsync.whenOrNull(data: (a) => a?.patientId);
    final patientAsync = patientId != null
        ? ref.watch(patientByIdProvider(patientId))
        : const AsyncValue<Patient?>.data(null);

    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Patient Info Card ──────────────────────────
          _buildPatientInfoCard(
            context,
            theme,
            patientAsync,
            admissionAsync,
            syndromeNamesAsync,
            authState,
          ),
          const SizedBox(height: 20),

          // ── Simulate Hospital Day ─────────────────────
          Text(
            'SIMULATE HOSPITAL DAY',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          _buildDaySelector(context, ref, effectiveDayAsync),
          const SizedBox(height: 20),

          // ── Overall Progress Card ─────────────────────
          _buildOverallProgressCard(context, theme, progressAsync),
          const SizedBox(height: 16),

          // ── Domain Progress Grid ──────────────────────
          _buildDomainProgressGrid(context, theme, progressAsync),
        ],
      ),
    );
  }

  // ── Patient Info Card ──────────────────────────────────────────────

  Widget _buildPatientInfoCard(
    BuildContext context,
    ThemeData theme,
    AsyncValue<Patient?> patientAsync,
    AsyncValue<Admission?> admissionAsync,
    AsyncValue<List<String>> syndromeNamesAsync,
    AuthState authState,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.patientCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: patientAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (_, _) => const Text('Error loading patient',
            style: TextStyle(color: Colors.white)),
        data: (patient) {
          final admission = admissionAsync.valueOrNull;
          final syndromeNames = syndromeNamesAsync.valueOrNull ?? [];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column — patient details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient?.name ?? 'Unknown Patient',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${patient?.age ?? "?"}y / ${patient?.sex ?? "?"} · UHID: ${patient?.uhid ?? "---"}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    if (admission?.bedNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        admission!.bedNumber!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white60),
                        const SizedBox(width: 6),
                        Text(
                          'Admitted: ${admission != null ? DateFormat('EEEE, d MMM yyyy').format(admission.admissionDate) : "---"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.white60),
                        const SizedBox(width: 6),
                        Text(
                          'Dr. ${authState.user?.name ?? "You"} (${_roleLabel(authState.user?.role)})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right column — syndrome badges
              if (syndromeNames.isNotEmpty) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SYNDROME',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...syndromeNames.map((name) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.day2.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.jr1:
        return 'JR1';
      case UserRole.jr2:
        return 'JR2';
      case UserRole.jr3:
        return 'JR3';
      case UserRole.consultant:
        return 'Consultant';
      case UserRole.admin:
        return 'Admin';
      case null:
        return 'JR2';
    }
  }

  // ── Day Selector ──────────────────────────────────────────────────

  Widget _buildDaySelector(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> effectiveDayAsync,
  ) {
    final effectiveDay = effectiveDayAsync.valueOrNull ?? 1;
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          final day = index + 1;
          final isSelected = day == effectiveDay;
          final dayColor = WorkupHelpers.dayColor(day);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${dayNames[index]} (Day $day)'),
              selected: isSelected,
              selectedColor: dayColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(simulatedDayProvider(admissionId).notifier)
                      .state = day;
                }
              },
            ),
          );
        }),
      ),
    );
  }

  // ── Overall Progress Card ─────────────────────────────────────────

  Widget _buildOverallProgressCard(
    BuildContext context,
    ThemeData theme,
    AsyncValue<WorkupProgress> progressAsync,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: progressAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Text('Error loading progress'),
          data: (progress) {
            final percent = progress.overallPercent;
            final percentInt = (percent * 100).round();
            final color = WorkupHelpers.progressColor(percent);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall Workup Progress',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '$percentInt%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    color: color,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progress.completedItems} of ${progress.totalItems} items complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Required: ${progress.requiredCompleted}/${progress.requiredItems}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Domain Progress Grid ──────────────────────────────────────────

  Widget _buildDomainProgressGrid(
    BuildContext context,
    ThemeData theme,
    AsyncValue<WorkupProgress> progressAsync,
  ) {
    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (progress) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: WorkupHelpers.clinicalDomains.asMap().entries.map((entry) {
            final index = entry.key;
            final domain = entry.value;
            final dp = progress.byDomain[domain];
            return _DomainProgressCard(
              domain: domain,
              total: dp?.total ?? 0,
              completed: dp?.completed ?? 0,
              onTap: () {
                // Tab indices: 0=Overview, 1-6=domains
                tabController.animateTo(index + 1);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _DomainProgressCard extends StatelessWidget {
  final WorkupDomain domain;
  final int total;
  final int completed;
  final VoidCallback onTap;

  const _DomainProgressCard({
    required this.domain,
    required this.total,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total == 0 ? 0.0 : completed / total;
    final color = WorkupHelpers.progressColor(percent);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WorkupHelpers.domainLabel(domain),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completed/$total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

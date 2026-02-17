import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/patient_providers.dart';
import '../../providers/workup_providers.dart';

class TimelineViewScreen extends ConsumerWidget {
  final String admissionId;
  const TimelineViewScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(workupItemsProvider(admissionId));
    final admissionAsync = ref.watch(admissionByIdProvider(admissionId));

    // Resolve patient
    final patientId =
        admissionAsync.whenOrNull(data: (a) => a?.patientId);
    final patientAsync = patientId != null
        ? ref.watch(patientByIdProvider(patientId))
        : const AsyncValue<Patient?>.data(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Day Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Workup Dashboard',
            onPressed: () => context.push('/workup/$admissionId'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Patient Summary Bar ─────────────────────────
          _buildPatientBar(context, theme, admissionAsync, patientAsync),

          // ── Timeline Columns ────────────────────────────
          Expanded(
            child: itemsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (items) =>
                  _buildTimeline(context, theme, items, admissionAsync),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientBar(
    BuildContext context,
    ThemeData theme,
    AsyncValue<Admission?> admissionAsync,
    AsyncValue<Patient?> patientAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
              color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          admissionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (adm) {
              if (adm == null) return const SizedBox.shrink();
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _dayColor(adm.currentDay),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D${adm.currentDay}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: patientAsync.when(
              loading: () => const Text('Loading...'),
              error: (_, _) => const Text('Unknown'),
              data: (patient) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient?.name ?? 'Unknown',
                      style: theme.textTheme.titleSmall),
                  Text(
                    'Bed ${admissionAsync.valueOrNull?.bedNumber ?? "---"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    ThemeData theme,
    List<WorkupItem> items,
    AsyncValue<Admission?> admissionAsync,
  ) {
    // Group items by targetDay
    final grouped = <int?, List<WorkupItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.targetDay, () => []).add(item);
    }

    final columnWidth = MediaQuery.of(context).size.width * 0.42;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day 1-5 columns
          for (int day = 1; day <= 5; day++)
            _buildDayColumn(
              context,
              theme,
              'Day $day',
              _dayColor(day),
              grouped[day] ?? [],
              columnWidth,
              admissionAsync.valueOrNull?.currentDay ?? 1,
              day,
            ),
          // "No Day" column
          _buildDayColumn(
            context,
            theme,
            'No Day',
            Colors.grey,
            grouped[null] ?? [],
            columnWidth,
            admissionAsync.valueOrNull?.currentDay ?? 1,
            0,
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    ThemeData theme,
    String title,
    Color color,
    List<WorkupItem> items,
    double width,
    int currentDay,
    int dayNum,
  ) {
    final isCurrentDay = dayNum == currentDay && dayNum > 0;

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isCurrentDay
            ? Border.all(color: color, width: 2)
            : Border.all(
                color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${items.length}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: color)),
                ),
              ],
            ),
          ),
          // Items
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('No items',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(6),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _TimelineItemCard(item: items[index]),
                  ),
          ),
        ],
      ),
    );
  }

  static Color _dayColor(int day) {
    switch (day) {
      case 1:
        return AppTheme.day1;
      case 2:
        return AppTheme.day2;
      case 3:
        return AppTheme.day3;
      case 4:
        return AppTheme.day4;
      default:
        return AppTheme.day5;
    }
  }
}

class _TimelineItemCard extends StatelessWidget {
  final WorkupItem item;
  const _TimelineItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(item.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status color bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_domainIcon(item.domain),
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _statusLabel(item.status),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: statusColor),
                          ),
                        ),
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

  static Color _statusColor(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return AppTheme.statusPending;
      case WorkupStatus.ordered:
        return AppTheme.statusOrdered;
      case WorkupStatus.sent:
      case WorkupStatus.resulted:
      case WorkupStatus.reviewed:
        return AppTheme.statusSent;
      case WorkupStatus.done:
        return AppTheme.statusDone;
      case WorkupStatus.notApplicable:
      case WorkupStatus.deferredOpd:
        return Colors.grey;
    }
  }

  static String _statusLabel(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return 'Pending';
      case WorkupStatus.ordered:
        return 'Ordered';
      case WorkupStatus.sent:
        return 'Sent';
      case WorkupStatus.resulted:
        return 'Resulted';
      case WorkupStatus.reviewed:
        return 'Reviewed';
      case WorkupStatus.done:
        return 'Done';
      case WorkupStatus.notApplicable:
        return 'N/A';
      case WorkupStatus.deferredOpd:
        return 'Deferred';
    }
  }

  static IconData _domainIcon(WorkupDomain domain) {
    switch (domain) {
      case WorkupDomain.history:
        return Icons.history_edu;
      case WorkupDomain.examination:
        return Icons.medical_services_outlined;
      case WorkupDomain.blood:
        return Icons.bloodtype_outlined;
      case WorkupDomain.radiology:
        return Icons.image_outlined;
      case WorkupDomain.treatment:
        return Icons.medication_outlined;
      case WorkupDomain.referral:
        return Icons.group_outlined;
      case WorkupDomain.schemePrereq:
        return Icons.card_membership_outlined;
      case WorkupDomain.discharge:
        return Icons.exit_to_app;
    }
  }
}

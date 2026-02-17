import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/workup_providers.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(allTasksProvider),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('All Caught Up!',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('No pending tasks across your admissions.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (groups.overdue.isNotEmpty) ...[
                _sectionHeader(context, Icons.warning,
                    'Overdue', groups.overdue.length, AppTheme.statusOverdue),
                ...groups.overdue.map((t) => _taskTile(context, theme, t)),
              ],
              if (groups.today.isNotEmpty) ...[
                _sectionHeader(context, Icons.today,
                    'Today', groups.today.length, AppTheme.day1),
                ...groups.today.map((t) => _taskTile(context, theme, t)),
              ],
              if (groups.upcoming.isNotEmpty) ...[
                _sectionHeader(context, Icons.schedule,
                    'Upcoming', groups.upcoming.length, AppTheme.day2),
                ...groups.upcoming.map((t) => _taskTile(context, theme, t)),
              ],
              if (groups.noDay.isNotEmpty) ...[
                _sectionHeader(context, Icons.event_note_outlined,
                    'Unscheduled', groups.noDay.length, Colors.grey),
                ...groups.noDay.map((t) => _taskTile(context, theme, t)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title,
      int count, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: theme.textTheme.labelSmall?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _taskTile(BuildContext context, ThemeData theme, TaskItem task) {
    final item = task.workupItem;
    final statusColor = _statusColor(item.status);

    return Card(
      child: ListTile(
        leading: Icon(_domainIcon(item.domain),
            color: theme.colorScheme.primary),
        title: Text(item.itemText,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${task.patient.name} \u2022 Bed ${task.admission.bedNumber ?? "---"} \u2022 Day ${item.targetDay ?? "?"}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _statusLabel(item.status),
            style:
                theme.textTheme.labelSmall?.copyWith(color: statusColor),
          ),
        ),
        onTap: () => context.push('/workup/${task.admission.id}'),
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

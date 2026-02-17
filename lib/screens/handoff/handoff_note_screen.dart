import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/patient_providers.dart';
import '../../providers/syndrome_providers.dart';
import '../../providers/workup_providers.dart';

class HandoffNoteScreen extends ConsumerWidget {
  final String admissionId;
  const HandoffNoteScreen({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final admissionAsync = ref.watch(admissionByIdProvider(admissionId));
    final itemsAsync = ref.watch(workupItemsProvider(admissionId));
    final syndromesAsync =
        ref.watch(admissionSyndromesProvider(admissionId));
    final allSyndromes = ref.watch(syndromeProtocolsProvider);

    // Resolve patient
    final patientId =
        admissionAsync.whenOrNull(data: (a) => a?.patientId);
    final patientAsync = patientId != null
        ? ref.watch(patientByIdProvider(patientId))
        : const AsyncValue<Patient?>.data(null);

    // Check if all data is loaded
    final isLoading = admissionAsync.isLoading ||
        itemsAsync.isLoading ||
        patientAsync.isLoading;
    final hasError = admissionAsync.hasError ||
        itemsAsync.hasError ||
        patientAsync.hasError;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shift Handoff Note')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shift Handoff Note')),
        body: const Center(child: Text('Error loading data')),
      );
    }

    final admission = admissionAsync.valueOrNull;
    final patient = patientAsync.valueOrNull;
    final items = itemsAsync.valueOrNull ?? [];
    final syndromeLinks = syndromesAsync.valueOrNull ?? [];
    final syndromeMap = {
      for (final sp in allSyndromes.valueOrNull ?? <SyndromeProtocol>[])
        sp.id: sp.name
    };
    final syndromeNames = syndromeLinks
        .map((s) => syndromeMap[s.syndromeId] ?? s.syndromeId)
        .toList();

    if (admission == null || patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shift Handoff Note')),
        body: const Center(child: Text('Admission not found')),
      );
    }

    // Categorize items
    const completedStatuses = {
      WorkupStatus.done,
      WorkupStatus.notApplicable,
    };
    final pendingItems =
        items.where((i) => !completedStatuses.contains(i.status)).toList();
    final completedToday = items.where((i) {
      if (i.completedAt == null) return false;
      final today = DateTime.now();
      return i.completedAt!.year == today.year &&
          i.completedAt!.month == today.month &&
          i.completedAt!.day == today.day;
    }).toList();
    final hardBlocks = items
        .where(
            (i) => i.isHardBlock && !completedStatuses.contains(i.status))
        .toList();
    final overdueItems = items
        .where((i) =>
            !completedStatuses.contains(i.status) &&
            i.targetDay != null &&
            i.targetDay! < admission.currentDay)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Handoff Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy to Clipboard',
            onPressed: () {
              final text = _buildHandoffText(
                patient,
                admission,
                syndromeNames,
                pendingItems,
                completedToday,
                hardBlocks,
                overdueItems,
              );
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Handoff note copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Patient Summary ────────────────────────
            _card(
              context,
              theme,
              'Patient Summary',
              Icons.person_outlined,
              theme.colorScheme.primary,
              [
                _row('Name', patient.name),
                _row('Age / Sex', '${patient.age}${patient.sex}'),
                _row('UHID', patient.uhid),
                _row('Bed', admission.bedNumber ?? '---'),
                _row('Current Day', 'Day ${admission.currentDay}'),
                _row(
                    'Admitted',
                    DateFormat('dd MMM yyyy')
                        .format(admission.admissionDate)),
                _row('Syndromes', syndromeNames.join(', ')),
              ],
            ),
            const SizedBox(height: 12),

            // ── 2. Pending Items ──────────────────────────
            _card(
              context,
              theme,
              'Pending Items (${pendingItems.length})',
              Icons.pending_actions,
              AppTheme.statusOrdered,
              pendingItems.isEmpty
                  ? [
                      const Text('No pending items'),
                    ]
                  : _groupedItemWidgets(theme, pendingItems),
            ),
            const SizedBox(height: 12),

            // ── 3. Completed Today ────────────────────────
            _card(
              context,
              theme,
              'Completed Today (${completedToday.length})',
              Icons.check_circle_outline,
              AppTheme.statusDone,
              completedToday.isEmpty
                  ? [
                      Text('No items completed today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ]
                  : completedToday
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check,
                                    size: 16, color: AppTheme.statusDone),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${item.itemText}${item.resultValue != null ? " — ${item.resultValue}" : ""}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
            ),
            const SizedBox(height: 12),

            // ── 4. Key Alerts ─────────────────────────────
            _alertCard(
              context,
              theme,
              hardBlocks,
              overdueItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, ThemeData theme, String title,
      IconData icon, Color color, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  List<Widget> _groupedItemWidgets(
      ThemeData theme, List<WorkupItem> items) {
    final grouped = <WorkupDomain, List<WorkupItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.domain, () => []).add(item);
    }

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Text(
          entry.key.name[0].toUpperCase() + entry.key.name.substring(1),
          style: theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ));
      for (final item in entry.value) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u2022 ', style: theme.textTheme.bodySmall),
              Expanded(
                child: Text(
                  '${item.itemText} [${item.status.name}]',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _alertCard(BuildContext context, ThemeData theme,
      List<WorkupItem> hardBlocks, List<WorkupItem> overdueItems) {
    final hasAlerts = hardBlocks.isNotEmpty || overdueItems.isNotEmpty;

    return Card(
      color: hasAlerts
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
          : AppTheme.success.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasAlerts
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                  size: 20,
                  color: hasAlerts
                      ? theme.colorScheme.error
                      : AppTheme.statusDone,
                ),
                const SizedBox(width: 8),
                Text('Key Alerts',
                    style: theme.textTheme.titleSmall),
              ],
            ),
            const Divider(height: 16),
            if (!hasAlerts)
              Row(
                children: [
                  const Icon(Icons.check,
                      size: 16, color: AppTheme.statusDone),
                  const SizedBox(width: 6),
                  Text('No active alerts',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.statusDone)),
                ],
              ),
            if (hardBlocks.isNotEmpty) ...[
              Text('Hard Blocks:',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.error)),
              ...hardBlocks.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.block,
                            size: 14, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(item.itemText,
                                style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],
            if (overdueItems.isNotEmpty) ...[
              Text('Overdue Items:',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: AppTheme.statusOverdue)),
              ...overdueItems.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule,
                            size: 14, color: AppTheme.statusOverdue),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(
                                '${item.itemText} (Day ${item.targetDay})',
                                style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _buildHandoffText(
    Patient patient,
    Admission admission,
    List<String> syndromeNames,
    List<WorkupItem> pendingItems,
    List<WorkupItem> completedToday,
    List<WorkupItem> hardBlocks,
    List<WorkupItem> overdueItems,
  ) {
    final buf = StringBuffer();
    buf.writeln('=== SHIFT HANDOFF NOTE ===');
    buf.writeln(
        'Generated: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}');
    buf.writeln();
    buf.writeln('--- Patient Summary ---');
    buf.writeln('Name: ${patient.name} (${patient.age}${patient.sex})');
    buf.writeln('UHID: ${patient.uhid}');
    buf.writeln('Bed: ${admission.bedNumber ?? "---"}');
    buf.writeln('Day: ${admission.currentDay}');
    buf.writeln(
        'Admitted: ${DateFormat('dd MMM yyyy').format(admission.admissionDate)}');
    buf.writeln('Syndromes: ${syndromeNames.join(", ")}');
    buf.writeln();

    buf.writeln('--- Pending Items (${pendingItems.length}) ---');
    if (pendingItems.isEmpty) {
      buf.writeln('None');
    } else {
      for (final item in pendingItems) {
        buf.writeln('  - ${item.itemText} [${item.status.name}]');
      }
    }
    buf.writeln();

    buf.writeln('--- Completed Today (${completedToday.length}) ---');
    if (completedToday.isEmpty) {
      buf.writeln('None');
    } else {
      for (final item in completedToday) {
        buf.writeln(
            '  - ${item.itemText}${item.resultValue != null ? " = ${item.resultValue}" : ""}');
      }
    }
    buf.writeln();

    buf.writeln('--- Alerts ---');
    if (hardBlocks.isEmpty && overdueItems.isEmpty) {
      buf.writeln('No active alerts');
    } else {
      if (hardBlocks.isNotEmpty) {
        buf.writeln('Hard Blocks:');
        for (final item in hardBlocks) {
          buf.writeln('  [BLOCK] ${item.itemText}');
        }
      }
      if (overdueItems.isNotEmpty) {
        buf.writeln('Overdue:');
        for (final item in overdueItems) {
          buf.writeln('  [OVERDUE] ${item.itemText} (Day ${item.targetDay})');
        }
      }
    }

    return buf.toString();
  }
}

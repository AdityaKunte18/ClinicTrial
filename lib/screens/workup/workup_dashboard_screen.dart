import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/workup_providers.dart';

class WorkupDashboardScreen extends ConsumerStatefulWidget {
  final String admissionId;
  const WorkupDashboardScreen({super.key, required this.admissionId});

  @override
  ConsumerState<WorkupDashboardScreen> createState() =>
      _WorkupDashboardScreenState();
}

class _WorkupDashboardScreenState
    extends ConsumerState<WorkupDashboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabDomains = [
    WorkupDomain.history,
    WorkupDomain.examination,
    WorkupDomain.blood,
    WorkupDomain.radiology,
    WorkupDomain.treatment,
    WorkupDomain.referral,
  ];

  static const _domainLabels = {
    WorkupDomain.history: 'History',
    WorkupDomain.examination: 'Exam',
    WorkupDomain.blood: 'Blood',
    WorkupDomain.radiology: 'Radiology',
    WorkupDomain.treatment: 'Treatment',
    WorkupDomain.referral: 'Referrals',
  };

  static const _domainIcons = {
    WorkupDomain.history: Icons.history_edu,
    WorkupDomain.examination: Icons.medical_services_outlined,
    WorkupDomain.blood: Icons.bloodtype_outlined,
    WorkupDomain.radiology: Icons.image_outlined,
    WorkupDomain.treatment: Icons.medication_outlined,
    WorkupDomain.referral: Icons.group_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabDomains.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final admissionAsync = ref.watch(admissionByIdProvider(widget.admissionId));
    final itemsByDomainAsync =
        ref.watch(workupItemsByDomainProvider(widget.admissionId));
    final syndromesAsync =
        ref.watch(admissionSyndromesProvider(widget.admissionId));

    // Resolve patient from admission
    final patientId = admissionAsync.whenOrNull(data: (a) => a?.patientId);
    final patientAsync = patientId != null
        ? ref.watch(patientByIdProvider(patientId))
        : const AsyncValue<Patient?>.data(null);

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Workup Dashboard'),
          data: (patient) {
            final syndromeNames = syndromesAsync.whenOrNull(
                    data: (list) =>
                        list.map((s) => s.syndromeId).join(', ')) ??
                '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient?.name ?? 'Unknown Patient',
                    style: theme.textTheme.titleMedium),
                if (syndromeNames.isNotEmpty)
                  Text(syndromeNames,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'Timeline',
            onPressed: () =>
                context.push('/timeline/${widget.admissionId}'),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            tooltip: 'Handoff Note',
            onPressed: () =>
                context.push('/handoff/${widget.admissionId}'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabDomains.map((d) {
            return Tab(
              icon: Icon(_domainIcons[d], size: 20),
              text: _domainLabels[d],
            );
          }).toList(),
        ),
      ),
      body: itemsByDomainAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text('Error loading workup items',
                  style: theme.textTheme.titleMedium),
              Text(err.toString(), style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref
                    .invalidate(workupItemsByDomainProvider(widget.admissionId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (itemsByDomain) {
          return TabBarView(
            controller: _tabController,
            children: _tabDomains.map((domain) {
              final items = itemsByDomain[domain] ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_domainIcons[domain] ?? Icons.info_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                          'No ${_domainLabels[domain] ?? domain.name} items',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _WorkupItemCard(
                      item: items[index],
                      admissionId: widget.admissionId,
                    ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/discharge/${widget.admissionId}'),
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Discharge Check'),
      ),
    );
  }
}

// ── Workup Item Card ────────────────────────────────────────────────

class _WorkupItemCard extends ConsumerWidget {
  final WorkupItem item;
  final String admissionId;

  const _WorkupItemCard({required this.item, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showStatusUpdateSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _statusIcon(item.status),
                  size: 18,
                  color: _statusColor(item.status),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemText,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.targetDay != null)
                          _chip(
                            'Day ${item.targetDay}',
                            _dayColor(item.targetDay!),
                            theme,
                          ),
                        _chip(
                          _statusLabel(item.status),
                          _statusColor(item.status),
                          theme,
                        ),
                        if (item.isHardBlock)
                          _chip('Hard Block', theme.colorScheme.error, theme),
                        if (item.isRequired && !item.isHardBlock)
                          _chip('Required', theme.colorScheme.primary, theme),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _StatusUpdateSheet(
        item: item,
        admissionId: admissionId,
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
        return AppTheme.statusSent;
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

  static IconData _statusIcon(WorkupStatus status) {
    switch (status) {
      case WorkupStatus.pending:
        return Icons.circle_outlined;
      case WorkupStatus.ordered:
        return Icons.schedule;
      case WorkupStatus.sent:
        return Icons.send;
      case WorkupStatus.resulted:
        return Icons.assignment_turned_in_outlined;
      case WorkupStatus.reviewed:
        return Icons.fact_check_outlined;
      case WorkupStatus.done:
        return Icons.check_circle;
      case WorkupStatus.notApplicable:
        return Icons.remove_circle_outline;
      case WorkupStatus.deferredOpd:
        return Icons.event_note_outlined;
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
        return 'Deferred OPD';
    }
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

// ── Status Update Bottom Sheet ──────────────────────────────────────

class _StatusUpdateSheet extends ConsumerStatefulWidget {
  final WorkupItem item;
  final String admissionId;

  const _StatusUpdateSheet({
    required this.item,
    required this.admissionId,
  });

  @override
  ConsumerState<_StatusUpdateSheet> createState() =>
      _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends ConsumerState<_StatusUpdateSheet> {
  late WorkupStatus _selectedStatus;
  late TextEditingController _resultCtrl;
  late TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.item.status;
    _resultCtrl = TextEditingController(text: widget.item.resultValue ?? '');
    _notesCtrl = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _resultCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(widget.item.itemText,
                style: theme.textTheme.titleMedium),
            if (widget.item.isHardBlock) ...[
              const SizedBox(height: 4),
              Text('Hard Block',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),

            // Status selection
            Text('Status', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: WorkupStatus.values.map((status) {
                final selected = status == _selectedStatus;
                return ChoiceChip(
                  label: Text(_WorkupItemCard._statusLabel(status)),
                  selected: selected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedStatus = status);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Result value (show when resulted or beyond)
            if (_selectedStatus.index >= WorkupStatus.resulted.index) ...[
              TextField(
                controller: _resultCtrl,
                decoration: InputDecoration(
                  labelText: 'Result Value',
                  hintText: 'Enter result...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Notes
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final authState = ref.read(authProvider);
      final updated = widget.item.copyWith(
        status: _selectedStatus,
        resultValue: _resultCtrl.text.isEmpty ? null : _resultCtrl.text,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        completedBy: _selectedStatus == WorkupStatus.done
            ? authState.user?.id
            : null,
        completedAt:
            _selectedStatus == WorkupStatus.done ? DateTime.now() : null,
      );
      final repo = ref.read(dataRepositoryProvider);
      await repo.updateWorkupItem(updated);
      ref.invalidate(workupItemsProvider(widget.admissionId));
      ref.invalidate(workupItemsByDomainProvider(widget.admissionId));
      ref.invalidate(dischargeCheckProvider(widget.admissionId));
      ref.invalidate(allTasksProvider);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

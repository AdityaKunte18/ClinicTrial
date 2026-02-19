import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/classification_providers.dart';
import '../../../providers/patient_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/workup_providers.dart';
import '../widgets/ai_suggestion_banner.dart';
import '../widgets/result_picker.dart';
import '../widgets/workup_helpers.dart';

/// Tab content for a single workup domain — shows list of workup items.
class DomainTab extends ConsumerWidget {
  final String admissionId;
  final WorkupDomain domain;

  const DomainTab({
    super.key,
    required this.admissionId,
    required this.domain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemsByDomainAsync =
        ref.watch(workupItemsByDomainProvider(admissionId));
    final syndromesAsync =
        ref.watch(admissionSyndromesProvider(admissionId));

    return itemsByDomainAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (itemsByDomain) {
        final items = itemsByDomain[domain] ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(WorkupHelpers.domainIcon(domain),
                    size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(
                  'No ${WorkupHelpers.domainTabLabel(domain)} items',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        // Get syndrome IDs for AI suggestion banners
        final syndromeIds = syndromesAsync.valueOrNull
                ?.map((s) => s.syndromeId)
                .toList() ??
            <String>[];

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: items.length + syndromeIds.length,
          itemBuilder: (context, index) {
            // Show AI suggestion banners first
            if (index < syndromeIds.length) {
              return AiSuggestionBanner(
                admissionId: admissionId,
                syndromeId: syndromeIds[index],
              );
            }
            final itemIndex = index - syndromeIds.length;
            return _WorkupItemCard(
              item: items[itemIndex],
              admissionId: admissionId,
            );
          },
        );
      },
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
                  color: WorkupHelpers.statusColor(item.status)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  WorkupHelpers.statusIcon(item.status),
                  size: 18,
                  color: WorkupHelpers.statusColor(item.status),
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
                            WorkupHelpers.dayColor(item.targetDay!),
                            theme,
                          ),
                        _chip(
                          WorkupHelpers.statusLabel(item.status),
                          WorkupHelpers.statusColor(item.status),
                          theme,
                        ),
                        if (item.isHardBlock)
                          _chip(
                              'Hard Block', theme.colorScheme.error, theme),
                        if (item.isRequired && !item.isHardBlock)
                          _chip(
                              'Required', theme.colorScheme.primary, theme),
                        if (item.classificationEventId != null)
                          _chip('AI Added',
                              theme.colorScheme.tertiary, theme),
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
  String? _selectedResultOptionId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.item.status;
    _resultCtrl = TextEditingController(text: widget.item.resultValue ?? '');
    _notesCtrl = TextEditingController(text: widget.item.notes ?? '');
    _selectedResultOptionId = widget.item.resultOptionId;
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
    final hasStructuredOptions = widget.item.templateItemId != null &&
        widget.item.syndromeId != null;

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
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
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
                  label: Text(WorkupHelpers.statusLabel(status)),
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
              // Structured result picker (if available)
              if (hasStructuredOptions)
                ResultPicker(
                  templateItemId: widget.item.templateItemId,
                  syndromeId: widget.item.syndromeId,
                  selectedOptionId: _selectedResultOptionId,
                  onSelected: (option) {
                    setState(() {
                      _selectedResultOptionId = option.id;
                      _resultCtrl.text = option.value ?? option.label;
                    });
                  },
                ),
              // Free-text fallback
              TextField(
                controller: _resultCtrl,
                decoration: InputDecoration(
                  labelText: hasStructuredOptions
                      ? 'Custom Result (or use options above)'
                      : 'Result Value',
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
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
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
        resultValue:
            _resultCtrl.text.isEmpty ? null : _resultCtrl.text,
        resultOptionId: _selectedResultOptionId,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        completedBy: _selectedStatus == WorkupStatus.done
            ? authState.user?.id
            : null,
        completedAt: _selectedStatus == WorkupStatus.done
            ? DateTime.now()
            : null,
      );
      final repo = ref.read(dataRepositoryProvider);
      await repo.updateWorkupItem(updated);
      ref.invalidate(workupItemsProvider(widget.admissionId));
      ref.invalidate(workupItemsByDomainProvider(widget.admissionId));
      ref.invalidate(dischargeCheckProvider(widget.admissionId));
      ref.invalidate(workupProgressProvider(widget.admissionId));
      ref.invalidate(allTasksProvider);
      // Invalidate classification providers so AI suggestions re-evaluate
      if (widget.item.syndromeId != null) {
        ref.invalidate(pendingAiSuggestionsProvider(
          (
            admissionId: widget.admissionId,
            syndromeId: widget.item.syndromeId!,
          ),
        ));
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/classification_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/workup_providers.dart';
import '../../../utils/workup_generator.dart';

/// Banner showing AI-suggested reclassification based on results.
/// Appears at the top of a domain tab when pending suggestions exist.
class AiSuggestionBanner extends ConsumerWidget {
  final String admissionId;
  final String syndromeId;

  const AiSuggestionBanner({
    super.key,
    required this.admissionId,
    required this.syndromeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(pendingAiSuggestionsProvider(
      (admissionId: admissionId, syndromeId: syndromeId),
    ));

    return suggestionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Column(
          children: suggestions
              .map((rule) => _SuggestionCard(
                    admissionId: admissionId,
                    syndromeId: syndromeId,
                    rule: rule,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SuggestionCard extends ConsumerStatefulWidget {
  final String admissionId;
  final String syndromeId;
  final ClassificationRule rule;

  const _SuggestionCard({
    required this.admissionId,
    required this.syndromeId,
    required this.rule,
  });

  @override
  ConsumerState<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends ConsumerState<_SuggestionCard> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rule = widget.rule;
    final guidelineText = rule.guidelines.isNotEmpty
        ? '${rule.guidelines.first.name}${rule.guidelines.first.section != null ? ' — ${rule.guidelines.first.section}' : ''}'
        : null;

    return Card(
      color: theme.colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Classification Suggestion',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on results, this patient may be: ${rule.classificationName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (guidelineText != null) ...[
              const SizedBox(height: 4),
              Text(
                guidelineText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (rule.additionalWorkupItems != null) ...[
              const SizedBox(height: 4),
              Text(
                'This will add new workup items to the order set.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _processing ? null : () => _dismiss(context),
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed:
                      _processing ? null : () => _accept(context),
                  icon: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    setState(() => _processing = true);
    try {
      final repo = ref.read(dataRepositoryProvider);
      final authState = ref.read(authProvider);
      final uuid = const Uuid();

      // Get previous classification
      final activeClass = await ref.read(activeClassificationProvider(
        (
          admissionId: widget.admissionId,
          syndromeId: widget.syndromeId,
        ),
      ).future);

      // Create classification event
      final event = ClassificationEvent(
        id: uuid.v4(),
        admissionId: widget.admissionId,
        syndromeId: widget.syndromeId,
        classificationRuleId: widget.rule.id,
        classificationName: widget.rule.classificationName,
        trigger: 'auto',
        previousClassification: activeClass?.classificationName,
        createdAt: DateTime.now(),
        createdBy: authState.user?.id,
      );
      await repo.createClassificationEvent(event);

      // Generate additional workup items if the rule specifies them
      if (widget.rule.additionalWorkupItems != null) {
        final newItems = generateClassificationItems(
          admissionId: widget.admissionId,
          syndromeId: widget.syndromeId,
          classificationEventId: event.id,
          additionalWorkup: widget.rule.additionalWorkupItems!,
        );
        if (newItems.isNotEmpty) {
          await repo.createWorkupItems(newItems);
        }
      }

      // Invalidate relevant providers
      ref.invalidate(classificationEventsProvider(widget.admissionId));
      ref.invalidate(workupItemsProvider(widget.admissionId));
      ref.invalidate(workupItemsByDomainProvider(widget.admissionId));
      ref.invalidate(workupProgressProvider(widget.admissionId));
      ref.invalidate(dischargeCheckProvider(widget.admissionId));
      ref.invalidate(allTasksProvider);
      ref.invalidate(pendingAiSuggestionsProvider(
        (
          admissionId: widget.admissionId,
          syndromeId: widget.syndromeId,
        ),
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Classification applied: ${widget.rule.classificationName}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _dismiss(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _OverrideReasonDialog(),
    );

    if (reason == null) return; // User cancelled

    setState(() => _processing = true);
    try {
      final repo = ref.read(dataRepositoryProvider);
      final authState = ref.read(authProvider);
      final uuid = const Uuid();

      final event = ClassificationEvent(
        id: uuid.v4(),
        admissionId: widget.admissionId,
        syndromeId: widget.syndromeId,
        classificationRuleId: widget.rule.id,
        classificationName: widget.rule.classificationName,
        trigger: 'doctor_override',
        overrideReason: reason,
        createdAt: DateTime.now(),
        createdBy: authState.user?.id,
      );
      await repo.createClassificationEvent(event);

      ref.invalidate(classificationEventsProvider(widget.admissionId));
      ref.invalidate(pendingAiSuggestionsProvider(
        (
          admissionId: widget.admissionId,
          syndromeId: widget.syndromeId,
        ),
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suggestion dismissed')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}

class _OverrideReasonDialog extends StatefulWidget {
  @override
  State<_OverrideReasonDialog> createState() => _OverrideReasonDialogState();
}

class _OverrideReasonDialogState extends State<_OverrideReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Override Reason'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Why are you dismissing this suggestion?',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            Navigator.pop(context, reason.isEmpty ? 'No reason given' : reason);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

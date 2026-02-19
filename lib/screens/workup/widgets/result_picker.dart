import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../providers/classification_providers.dart';

/// Radio-button result selector for structured result options.
/// Shows available options from the syndrome template if the item
/// has a templateItemId. Returns empty widget if no options exist.
class ResultPicker extends ConsumerWidget {
  final String? templateItemId;
  final String? syndromeId;
  final String? selectedOptionId;
  final ValueChanged<ResultOption> onSelected;

  const ResultPicker({
    super.key,
    required this.templateItemId,
    required this.syndromeId,
    required this.selectedOptionId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (templateItemId == null || syndromeId == null) {
      return const SizedBox.shrink();
    }

    final options = ref.watch(resultOptionsForItemProvider(
      (syndromeId: syndromeId!, templateItemId: templateItemId!),
    ));

    if (options.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Structured Result', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: options.map((option) {
              final isSelected = selectedOptionId == option.id;
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

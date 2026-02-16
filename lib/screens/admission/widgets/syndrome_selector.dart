import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../providers/syndrome_providers.dart';

/// Multi-select syndrome picker with search.
class SyndromeSelector extends ConsumerStatefulWidget {
  final List<String> selectedIds;
  final String? primaryId;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onSetPrimary;

  const SyndromeSelector({
    super.key,
    required this.selectedIds,
    this.primaryId,
    required this.onToggle,
    required this.onSetPrimary,
  });

  @override
  ConsumerState<SyndromeSelector> createState() => _SyndromeSelectorState();
}

class _SyndromeSelectorState extends ConsumerState<SyndromeSelector> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final protocolsAsync = ref.watch(syndromeProtocolsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'Search syndromes...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _search = v.toLowerCase()),
        ),
        const SizedBox(height: 12),

        // Selected count
        if (widget.selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.selectedIds.length} syndrome(s) selected',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),

        // Syndrome list
        Expanded(
          child: protocolsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (protocols) {
              // Filter
              final filtered = _search.isEmpty
                  ? protocols
                  : protocols.where((p) {
                      return p.name.toLowerCase().contains(_search) ||
                          p.code.toLowerCase().contains(_search) ||
                          (p.category?.toLowerCase().contains(_search) ?? false);
                    }).toList();

              // Group by category
              final grouped = <String, List<SyndromeProtocol>>{};
              for (final p in filtered) {
                final cat = p.category ?? 'Other';
                grouped.putIfAbsent(cat, () => []).add(p);
              }
              final categories = grouped.keys.toList()..sort();

              if (filtered.isEmpty) {
                return const Center(child: Text('No syndromes found'));
              }

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, catIndex) {
                  final cat = categories[catIndex];
                  final items = grouped[cat]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                        child: Text(
                          cat,
                          style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      ...items.map((protocol) {
                        final isSelected =
                            widget.selectedIds.contains(protocol.id);
                        final isPrimary = widget.primaryId == protocol.id;

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => widget.onToggle(protocol.id),
                          title: Text(protocol.name),
                          subtitle: Text(protocol.code,
                              style: theme.textTheme.bodySmall),
                          secondary: isSelected
                              ? IconButton(
                                  icon: Icon(
                                    isPrimary
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: isPrimary
                                        ? Colors.amber
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: isPrimary
                                      ? 'Primary syndrome'
                                      : 'Set as primary',
                                  onPressed: () =>
                                      widget.onSetPrimary(protocol.id),
                                )
                              : null,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

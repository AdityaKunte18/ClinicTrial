import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../providers/syndrome_providers.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  IconData _categoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'infectious / systemic':
        return Icons.bug_report_outlined;
      case 'respiratory':
        return Icons.air;
      case 'cardiovascular':
        return Icons.favorite_outline;
      case 'gi / hepatology':
        return Icons.restaurant_outlined;
      case 'renal':
      case 'renal / metabolic':
        return Icons.water_drop_outlined;
      case 'neurology':
        return Icons.psychology_outlined;
      case 'endocrine':
        return Icons.bloodtype_outlined;
      case 'hematology':
        return Icons.science_outlined;
      case 'rheumatology':
        return Icons.accessibility_new;
      case 'emergency':
        return Icons.emergency_outlined;
      case 'critical care':
        return Icons.monitor_heart_outlined;
      case 'nutrition':
        return Icons.restaurant;
      case 'oncology':
        return Icons.medical_services_outlined;
      case 'psychiatry':
        return Icons.psychology;
      case 'dermatology':
        return Icons.healing_outlined;
      default:
        return Icons.medical_information_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(syndromesGroupedByCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syndrome Templates'),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search syndromes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(syndromeSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                ref.read(syndromeSearchQueryProvider.notifier).state = v;
              },
            ),
          ),

          // Grouped list
          Expanded(
            child: groupedAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (grouped) {
                if (grouped.isEmpty) {
                  return const Center(child: Text('No syndromes found'));
                }

                final categories = grouped.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, catIndex) {
                    final cat = categories[catIndex];
                    final items = grouped[cat]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Row(
                            children: [
                              Icon(_categoryIcon(cat),
                                  size: 20,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                cat,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${items.length})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme
                                        .colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        // Syndrome tiles
                        ...items.map((protocol) => _syndromeListTile(
                            context, theme, protocol)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _syndromeListTile(
      BuildContext context, ThemeData theme, SyndromeProtocol protocol) {
    final itemCount = _countTemplateItems(protocol.baseTemplate);

    return ListTile(
      title: Text(protocol.name),
      subtitle: Text(
        '${protocol.code} · $itemCount items',
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings/templates/${protocol.id}'),
    );
  }

  int _countTemplateItems(Map<String, dynamic> template) {
    int count = 0;
    for (final value in template.values) {
      if (value is List) count += value.length;
    }
    return count;
  }
}

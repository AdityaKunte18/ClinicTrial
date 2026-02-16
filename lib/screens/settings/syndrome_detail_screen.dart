import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/syndrome_providers.dart';

/// Displays the full template contents of a syndrome, organized by domain tabs.
class SyndromeDetailScreen extends ConsumerWidget {
  final String syndromeId;

  const SyndromeDetailScreen({super.key, required this.syndromeId});

  static const _domainLabels = {
    'history': 'History',
    'examination': 'Examination',
    'blood_investigations': 'Blood',
    'radiology': 'Radiology',
    'treatment_orders': 'Treatment',
    'referrals': 'Referrals',
    'scheme_packages': 'Schemes',
    'discharge_criteria': 'Discharge',
  };

  static const _domainIcons = {
    'history': Icons.history_edu,
    'examination': Icons.medical_services_outlined,
    'blood_investigations': Icons.bloodtype_outlined,
    'radiology': Icons.image_outlined,
    'treatment_orders': Icons.medication_outlined,
    'referrals': Icons.group_outlined,
    'scheme_packages': Icons.card_membership_outlined,
    'discharge_criteria': Icons.exit_to_app,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protocolAsync = ref.watch(syndromeProtocolByIdProvider(syndromeId));
    final theme = Theme.of(context);

    return protocolAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (protocol) {
        if (protocol == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Syndrome not found')),
          );
        }

        final template = protocol.baseTemplate;
        // Only show domains that have data
        final domains = _domainLabels.keys
            .where((key) {
              final items = template[key];
              return items is List && items.isNotEmpty;
            })
            .toList();

        return DefaultTabController(
          length: domains.length,
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(protocol.name,
                      style: theme.textTheme.titleMedium),
                  Text(protocol.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                tabs: domains.map((d) {
                  return Tab(
                    icon: Icon(_domainIcons[d] ?? Icons.list, size: 20),
                    text: _domainLabels[d] ?? d,
                  );
                }).toList(),
              ),
            ),
            body: TabBarView(
              children: domains.map((domain) {
                final items = template[domain] as List? ?? [];
                return _buildDomainTab(theme, domain, items);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDomainTab(
      ThemeData theme, String domain, List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No items in this domain'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is! Map<String, dynamic>) {
          return ListTile(title: Text(item.toString()));
        }

        final text = item['text'] as String? ?? '—';
        final isRequired = item['required'] as bool? ?? false;
        final isHardBlock = item['hard_block'] as bool? ?? false;
        final day = item['day'] as int?;
        final category = item['category'] as String?;

        return ListTile(
          leading: _itemIcon(theme, isRequired, isHardBlock),
          title: Text(text),
          subtitle: _buildSubtitle(theme, day, category, isRequired, isHardBlock),
          dense: true,
        );
      },
    );
  }

  Widget _itemIcon(ThemeData theme, bool isRequired, bool isHardBlock) {
    if (isHardBlock) {
      return Icon(Icons.block, color: theme.colorScheme.error, size: 20);
    }
    if (isRequired) {
      return Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20);
    }
    return Icon(Icons.circle_outlined,
        color: theme.colorScheme.onSurfaceVariant, size: 20);
  }

  Widget? _buildSubtitle(ThemeData theme, int? day, String? category,
      bool isRequired, bool isHardBlock) {
    final parts = <String>[];
    if (day != null) {
      parts.add('Day $day');
    }
    if (category != null) {
      parts.add(category);
    }
    if (isHardBlock) {
      parts.add('Hard block');
    } else if (isRequired) {
      parts.add('Required');
    }

    if (parts.isEmpty) return null;

    return Text(
      parts.join(' · '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: isHardBlock
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

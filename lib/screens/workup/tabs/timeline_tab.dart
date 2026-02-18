import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../providers/workup_providers.dart';
import '../widgets/workup_helpers.dart';

/// Timeline tab content — horizontal 5-day column layout.
class TimelineTab extends ConsumerWidget {
  final String admissionId;
  const TimelineTab({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(workupItemsProvider(admissionId));
    final effectiveDayAsync = ref.watch(effectiveDayProvider(admissionId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        final effectiveDay = effectiveDayAsync.valueOrNull ?? 1;
        return _buildTimeline(context, theme, items, effectiveDay);
      },
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    ThemeData theme,
    List<WorkupItem> items,
    int effectiveDay,
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
          for (int day = 1; day <= 5; day++)
            _buildDayColumn(
              context,
              theme,
              'Day $day',
              WorkupHelpers.dayColor(day),
              grouped[day] ?? [],
              columnWidth,
              effectiveDay,
              day,
            ),
          _buildDayColumn(
            context,
            theme,
            'No Day',
            Colors.grey,
            grouped[null] ?? [],
            columnWidth,
            effectiveDay,
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
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: color, fontWeight: FontWeight.bold),
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
}

class _TimelineItemCard extends StatelessWidget {
  final WorkupItem item;
  const _TimelineItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = WorkupHelpers.statusColor(item.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
              ),
            ),
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
                        Icon(WorkupHelpers.domainIcon(item.domain),
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            WorkupHelpers.statusLabel(item.status),
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
}

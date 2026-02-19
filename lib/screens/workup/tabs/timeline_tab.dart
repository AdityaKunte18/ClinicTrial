import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/models.dart';
import '../../../providers/workup_providers.dart';
import '../widgets/workup_helpers.dart';

/// Timeline tab content — horizontal 5-day column layout with actual dates,
/// auto-shifted pending items, and auto-scroll to current day.
class TimelineTab extends ConsumerStatefulWidget {
  final String admissionId;
  const TimelineTab({super.key, required this.admissionId});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync =
        ref.watch(timelineDisplayItemsProvider(widget.admissionId));
    final effectiveDayAsync =
        ref.watch(effectiveDayProvider(widget.admissionId));
    final dayToDateAsync =
        ref.watch(dayToDateProvider(widget.admissionId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        final effectiveDay = effectiveDayAsync.valueOrNull ?? 1;
        final dayDates = dayToDateAsync.valueOrNull ?? {};
        return _buildTimeline(
            context, theme, items, effectiveDay, dayDates);
      },
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    ThemeData theme,
    List<WorkupItem> items,
    int effectiveDay,
    Map<int, DateTime> dayDates,
  ) {
    // Group items by targetDay
    final grouped = <int?, List<WorkupItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.targetDay, () => []).add(item);
    }

    final columnWidth = MediaQuery.of(context).size.width * 0.42;

    // Auto-scroll to current day after first build
    if (!_hasScrolled) {
      _hasScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final targetOffset =
              (effectiveDay - 1) * (columnWidth + 8);
          final maxOffset = _scrollController.position.maxScrollExtent;
          _scrollController.animateTo(
            targetOffset.clamp(0.0, maxOffset),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    }

    final dateFmt = DateFormat('EEE d MMM');

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int day = 1; day <= 5; day++)
            _buildDayColumn(
              context,
              theme,
              day,
              dayDates[day],
              dateFmt,
              WorkupHelpers.dayColor(day),
              grouped[day] ?? [],
              columnWidth,
              effectiveDay,
            ),
          _buildNoDayColumn(
            context,
            theme,
            grouped[null] ?? [],
            columnWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    ThemeData theme,
    int dayNum,
    DateTime? date,
    DateFormat dateFmt,
    Color color,
    List<WorkupItem> items,
    double width,
    int currentDay,
  ) {
    final isCurrentDay = dayNum == currentDay;
    final dateStr = date != null ? dateFmt.format(date) : '';

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
          // Column header with day + date
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day $dayNum',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: color, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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

  Widget _buildNoDayColumn(
    BuildContext context,
    ThemeData theme,
    List<WorkupItem> items,
    double width,
  ) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No Day',
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${items.length}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.grey)),
                ),
              ],
            ),
          ),
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
    final isShifted = item.originalTargetDay != null &&
        item.targetDay != null &&
        item.originalTargetDay != item.targetDay;

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
                    if (isShifted) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'from Day ${item.originalTargetDay}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../providers/workup_providers.dart';

/// Persistent bottom status bar shown across all workup dashboard tabs.
class PersistentBottomBar extends ConsumerWidget {
  final String admissionId;
  const PersistentBottomBar({super.key, required this.admissionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(workupProgressProvider(admissionId));
    final theme = Theme.of(context);

    return progressAsync.when(
      loading: () => SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (progress) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _BottomBarSection(
              label: 'Required',
              value: '${progress.requiredCompleted}/${progress.requiredItems}',
              valueColor: theme.colorScheme.error,
            ),
            _BottomBarSection(
              label: 'Total Items',
              value: '${progress.completedItems}/${progress.totalItems}',
              isBold: true,
            ),
            _BottomBarSection(
              label: 'Discharge',
              icon: progress.canDischarge ? Icons.check : Icons.close,
              iconColor: progress.canDischarge
                  ? AppTheme.statusDone
                  : theme.colorScheme.error,
            ),
            _BottomBarSection(
              label: 'Alerts',
              value: '${progress.alertCount}',
              valueColor: progress.alertCount > 0
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarSection extends StatelessWidget {
  final String label;
  final String? value;
  final bool isBold;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  const _BottomBarSection({
    required this.label,
    this.value,
    this.isBold = false,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 18, color: iconColor)
          else
            Text(
              value ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

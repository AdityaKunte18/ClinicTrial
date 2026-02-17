import 'package:flutter/material.dart';

class RemindersInboxScreen extends StatelessWidget {
  const RemindersInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 48),
            // ── Empty State ───────────────────────────────
            Icon(Icons.notifications_none_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No Active Reminders',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Reminders will appear here when workup items require attention. They escalate automatically based on urgency.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),

            // ── How Reminders Work ────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('How Reminders Work',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _levelRow(
                      context,
                      Icons.circle,
                      Colors.blue,
                      'Nudge',
                      'Gentle reminder for pending items',
                    ),
                    const SizedBox(height: 8),
                    _levelRow(
                      context,
                      Icons.circle,
                      Colors.amber,
                      'Firm',
                      'Item approaching deadline',
                    ),
                    const SizedBox(height: 8),
                    _levelRow(
                      context,
                      Icons.circle,
                      Colors.orange,
                      'Escalation',
                      'Overdue, escalated to senior',
                    ),
                    const SizedBox(height: 8),
                    _levelRow(
                      context,
                      Icons.circle,
                      Colors.red,
                      'Block',
                      'Discharge blocked until resolved',
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

  Widget _levelRow(BuildContext context, IconData icon, Color color,
      String label, String description) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(description,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class GuidelineUpdatesScreen extends StatelessWidget {
  const GuidelineUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Guideline Updates'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EmptyTab(
              status: 'Pending',
              description:
                  'When new clinical guidelines are detected that affect your syndrome protocols, they will appear here for review.',
            ),
            _EmptyTab(
              status: 'Accepted',
              description:
                  'Guidelines you have reviewed and accepted will be shown here. Accepted changes are applied to your protocols.',
            ),
            _EmptyTab(
              status: 'Rejected',
              description:
                  'Guidelines you have reviewed and rejected are kept here for reference.',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String status;
  final String description;

  const _EmptyTab({required this.status, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books_outlined,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No $status Updates',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

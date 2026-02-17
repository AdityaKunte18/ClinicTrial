import 'package:flutter/material.dart';

class AiConfigScreen extends StatelessWidget {
  const AiConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Features')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Coming Soon Banner ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'AI Features Coming Soon',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Intelligent clinical decision support powered by AI will be available in a future update.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Feature Toggles ─────────────────────────
            Text('Planned Features',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.auto_fix_high,
                        color: theme.colorScheme.onSurfaceVariant),
                    title: const Text('Auto-Syndrome Detection'),
                    subtitle: const Text(
                        'Automatically suggest syndromes from admission notes'),
                    value: false,
                    onChanged: null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.lightbulb_outline,
                        color: theme.colorScheme.onSurfaceVariant),
                    title: const Text('Clinical Suggestions'),
                    subtitle: const Text(
                        'AI-powered workup recommendations'),
                    value: false,
                    onChanged: null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.document_scanner_outlined,
                        color: theme.colorScheme.onSurfaceVariant),
                    title: const Text('Guideline Scanner'),
                    subtitle: const Text(
                        'Auto-scan medical literature for protocol updates'),
                    value: false,
                    onChanged: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── API Configuration ───────────────────────
            Text('API Configuration',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        hintText: 'Enter Claude API key...',
                        prefixIcon: const Icon(Icons.key_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'API configuration will be available when AI features are released.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router.dart';
import 'config/theme.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env may not exist on Vercel — that's OK)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file missing — Supabase will run in demo mode
  }

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: ClinicalPilotApp()));
}

class ClinicalPilotApp extends ConsumerWidget {
  const ClinicalPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ClinicalPilot',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

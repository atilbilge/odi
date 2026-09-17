import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/database/database_service.dart';
import 'core/services/notion_sync_service.dart';
import 'core/services/speech_service.dart';
import 'core/services/settings_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(); // Initialize intl locale data
  
  // Initialize Isar database
  final dbService = await DatabaseService.init();

  final container = ProviderContainer(
    overrides: [
      databaseServiceProvider.overrideWithValue(dbService),
      notionSyncServiceProvider.overrideWithValue(NotionSyncService(dbService)),
    ],
  );

  // Seed Notion token on first launch (if not already stored)
  Future.microtask(() async {
    try {
      final notionSvc = container.read(notionSyncServiceProvider);
      final existingToken = await notionSvc.getToken();
      if (existingToken == null || existingToken.isEmpty) {
        await notionSvc.saveToken('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');
      }
    } catch (_) {}
  });

  // Background initialization of SpeechService
  Future.microtask(() async {
    try {
      final settingsNotifier = container.read(settingsProvider.notifier);
      await settingsNotifier.loadSettings();
      final settings = container.read(settingsProvider);
      await container.read(speechServiceProvider).initialize(selectedVoice: settings.selectedVoice);
    } catch (_) {
      // Ignore background initialization errors
    }
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odi',
      debugShowCheckedModeBanner: false,
      theme: OdiTheme.light,
      home: const HomeScreen(),
    );
  }
}

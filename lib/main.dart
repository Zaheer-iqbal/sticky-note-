import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/core/routes/app_router.dart';
import 'package:sticky_notes/core/services/alarm_service.dart';
import 'package:sticky_notes/core/services/hive_service.dart';
import 'package:sticky_notes/core/services/notification_service.dart';
import 'package:sticky_notes/core/services/reminder_checker.dart';
import 'package:sticky_notes/core/themes/app_theme.dart';
import 'package:sticky_notes/features/settings/presentation/providers/settings_provider.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final reminderCheckerProvider = Provider<ReminderChecker>((ref) {
  return ReminderChecker();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await NotificationService.init();
  await AlarmService.init();
  runApp(
    const ProviderScope(
      child: NoteAlertApp(),
    ),
  );
}

class NoteAlertApp extends ConsumerStatefulWidget {
  const NoteAlertApp({super.key});

  @override
  ConsumerState<NoteAlertApp> createState() => _NoteAlertAppState();
}

class _NoteAlertAppState extends ConsumerState<NoteAlertApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigatorKey = ref.read(navigatorKeyProvider);
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        ref.read(reminderCheckerProvider).start(ref, navigator);
      }
    });
  }

  @override
  void dispose() {
    ref.read(reminderCheckerProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp.router(
      title: 'Sticky Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider(navigatorKey)),
    );
  }
}

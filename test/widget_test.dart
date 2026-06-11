import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sticky_notes/core/constants/app_constants.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/settings/data/models/settings_model.dart';
import 'package:sticky_notes/main.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    hiveDirectory = await Directory.systemTemp.createTemp('sticky_notes_test_');
    Hive.init(hiveDirectory.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    await Hive.openBox<NoteModel>(AppConstants.hiveBoxNotes);
    await Hive.openBox<SettingsModel>(AppConstants.hiveBoxSettings);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('shows empty notes screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NoteAlertApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NoteAlert'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Tap the + button to create your first note'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

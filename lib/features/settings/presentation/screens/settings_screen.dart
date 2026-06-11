import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sticky_notes/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark theme'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.amber : Colors.orange,
              ),
              value: isDark,
              onChanged: (_) =>
                  ref.read(settingsNotifierProvider.notifier).toggleDarkMode(),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Notifications'),
          Card(
            child: SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable reminder notifications'),
              secondary: const Icon(Icons.notifications_outlined),
              value: settings.notificationsEnabled,
              onChanged: (_) => ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleNotifications(),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Backup & Restore'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('Export Backup'),
                  subtitle: const Text('Save notes as JSON file'),
                  onTap: () => _exportBackup(ref, context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Import Backup'),
                  subtitle: const Text('Restore notes from JSON file'),
                  onTap: () => _importBackup(ref, context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'About'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('NoteAlert'),
              subtitle: const Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(WidgetRef ref, BuildContext context) async {
    try {
      final json = await ref.read(settingsNotifierProvider.notifier).exportBackup();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/notealert_backup.json');
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'NoteAlert Backup',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(WidgetRef ref, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final json = await file.readAsString();

      await ref.read(settingsNotifierProvider.notifier).importBackup(json);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade400
              : Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

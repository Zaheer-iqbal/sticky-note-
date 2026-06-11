import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/features/settings/presentation/providers/settings_provider.dart';
import 'package:sticky_notes/shared/widgets/edit_profile_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentName: settings.profileName,
        currentImagePath: settings.profileImagePath,
        onSave: (name, path) {
          ref.read(settingsNotifierProvider.notifier).updateProfile(name, path);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final profileImagePath = settings.profileImagePath;

    ImageProvider? avatarImage;
    if (profileImagePath.isNotEmpty) {
      if (profileImagePath.startsWith('http') || profileImagePath.startsWith('https')) {
        avatarImage = NetworkImage(profileImagePath);
      } else {
        avatarImage = FileImage(File(profileImagePath));
      }
    } else {
      avatarImage = const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256');
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7C3AED).withAlpha(51),
                          image: DecorationImage(
                            image: avatarImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'NoteAlert',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
                    onPressed: () => _showEditProfileDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Heading
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B1C30),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Manage your preferences and data',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // APPEARANCE SECTION
              _buildSectionHeader('APPEARANCE'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5EEFF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DAEF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF7C3AED)),
                    ),
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: const Text(
                      'Switch between light and dark themes',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
                    ),
                    trailing: Switch(
                      value: isDark,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (_) =>
                          ref.read(settingsNotifierProvider.notifier).toggleDarkMode(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // DATA SECTION
              _buildSectionHeader('DATA'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5EEFF)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF4F46E5)),
                      ),
                      title: const Text(
                        'Backup notes',
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Sync your notes to the cloud',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                      onTap: () => _exportBackup(ref, context),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEBD0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restore_outlined, color: Color(0xFFF59E0B)),
                      ),
                      title: const Text(
                        'Restore notes',
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Recover notes from a previous backup',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                      onTap: () => _importBackup(ref, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // APP INFO SECTION
              _buildSectionHeader('APP INFO'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5EEFF)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EEFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
                      ),
                      title: const Text(
                        'About',
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Version 2.4.0 (Build 100)',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'NoteAlert',
                          applicationVersion: '2.4.0 (Build 100)',
                          applicationIcon: const Icon(Icons.note_alt, color: Color(0xFF7C3AED)),
                          children: [
                            const Text('NoteAlert is a modern corporate minimalist productivity tool designed for focused note taking, alarms, and reminders.'),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EEFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                      ),
                      title: const Text(
                        'Privacy',
                        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Terms of service and data policy',
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 12),
                      ),
                      trailing: const Icon(Icons.open_in_new, color: Color(0xFF64748B), size: 18),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Privacy Policy', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
                            content: const SingleChildScrollView(
                              child: Text(
                                'NoteAlert Privacy Policy\nLast Updated: June 11, 2026\n\nNoteAlert is built as a commercial offline productivity tool.\n\n1. Data Collection & Storage\n- Your notes, alarm configurations, reminders, and profile details are stored entirely locally on your device using Hive database.\n- We do not collect, transmit, share, or store any personal data on external servers.\n- The "Backup notes" option exports your data as a local JSON file that you control entirely.\n\n2. Device Permissions\n- Notification Access: Required to trigger reminder notifications.\n- Alarm Permission: Required to wake the device screen and sound alarms.\n\n3. Children\'s Privacy\nThese Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13.\n\n4. Changes to This Policy\nWe may update our Privacy Policy. Since all data is local, changes will be documented inside app updates.\n\nContact Us: For support or inquiries, contact us locally or via developer email.',
                                style: TextStyle(fontFamily: 'Manrope', fontSize: 13, height: 1.4),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DANGER ZONE
              _buildSectionHeader('DANGER ZONE', color: const Color(0xFFBA1A1A)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: const Color(0xFFFFDAD6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFFDAD6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA1A1A).withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_forever_outlined, color: Color(0xFFBA1A1A)),
                    ),
                    title: const Text(
                      'Clear all notes',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFBA1A1A),
                      ),
                    ),
                    subtitle: const Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: Color(0xFF93000A),
                      ),
                    ),
                    onTap: () => _confirmClearAll(ref, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color color = const Color(0xFF4F46E5)}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmClearAll(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notes'),
        content: const Text('Are you sure you want to delete all notes? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(noteNotifierProvider.notifier).clearAllNotes();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notes cleared successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
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
      ref.read(noteNotifierProvider.notifier).loadNotes();

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

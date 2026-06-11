import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/features/notes/presentation/screens/main_navigation_screen.dart';
import 'package:sticky_notes/features/settings/presentation/providers/settings_provider.dart';
import 'package:sticky_notes/shared/utils/date_utils.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';
import 'package:sticky_notes/shared/widgets/empty_state.dart';
import 'package:sticky_notes/shared/widgets/edit_profile_dialog.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, $name';
    if (hour < 17) return 'Good Afternoon, $name';
    return 'Good Evening, $name';
  }

  void _showEditProfileDialog() {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final profileName = settings.profileName;
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
        child: notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (notes) {
            // Filter notes based on search query
            final filteredNotes = notes.where((n) {
              final query = _searchQuery.toLowerCase();
              return n.title.toLowerCase().contains(query) ||
                  n.description.toLowerCase().contains(query);
            }).toList();

            final pinnedNotes = filteredNotes.where((n) => n.isPinned).toList();
            final allNotes = filteredNotes.where((n) => !n.isPinned).toList();

            final upcomingReminders = notes
                .where((n) => n.reminderDateTime != null && n.reminderDateTime!.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.reminderDateTime!.compareTo(b.reminderDateTime!));

            if (notes.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => ref.read(noteNotifierProvider.notifier).loadNotes(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
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
                          onPressed: _showEditProfileDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Greeting text
                    Text(
                      _getGreeting(profileName),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1C30),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EEFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search your thoughts...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const Icon(Icons.tune, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Upcoming Reminders Section
                    if (upcomingReminders.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Reminders',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(currentTabProvider.notifier).state = 1; // switch to reminders tab
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: upcomingReminders.length,
                          itemBuilder: (context, index) {
                            final note = upcomingReminders[index];
                            final timeText = DateFormatUtils.relativeTime(note.reminderDateTime!);
                            return Container(
                              width: 240,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5EEFF), width: 1),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Due in $timeText',
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFF59E0B),
                                              ),
                                            ),
                                            if (note.alarmEnabled)
                                              const Icon(Icons.alarm, size: 14, color: Color(0xFFF59E0B)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          note.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF0B1C30),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          note.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Pinned Notes Section
                    if (pinnedNotes.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.push_pin, size: 16, color: Color(0xFF4F46E5)),
                          SizedBox(width: 8),
                          Text(
                            'PINNED NOTES',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...pinnedNotes.map((note) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF4FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFC7C4D8), width: 1),
                            ),
                            child: InkWell(
                              onTap: () => context.push('/note-details/${note.id}', extra: note),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color(0xFF0B1C30),
                                        ),
                                      ),
                                      const Icon(Icons.push_pin, size: 14, color: Color(0xFF4F46E5)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...() {
                                    final lines = note.description
                                        .split(RegExp(r'\r?\n'))
                                        .where((l) => l.trim().isNotEmpty)
                                        .toList();
                                    if (lines.isEmpty) return <Widget>[];
                                    return lines.map((line) {
                                      final cleanLine = line.replaceFirst(RegExp(r'^[\-\*•\s]+'), '');
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('• ',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF4F46E5))),
                                            Expanded(
                                              child: Text(
                                                cleanLine,
                                                style: const TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontSize: 13,
                                                  color: Color(0xFF464555),
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  }(),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                    // All Notes Section
                    const Text(
                      'All Notes',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (allNotes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No other notes match your search.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: allNotes.length,
                        itemBuilder: (context, index) {
                          final note = allNotes[index];
                          final bgColor = NoteColors.fromName(note.colorName);
                          return InkWell(
                            onTap: () => context.push('/note-details/${note.id}', extra: note),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: bgColor.withAlpha(200),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF0B1C30),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      note.description,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12,
                                        color: Color(0xFF464555),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (note.category.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(128),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        note.category,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0B1C30),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note-details/new'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Simple header on empty state
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NoteAlert',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4F46E5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  ref.read(currentTabProvider.notifier).state = 2;
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: EmptyState(
            icon: Icons.sticky_note_2_outlined,
            title: 'No Notes Yet',
            subtitle: 'Start capturing your thoughts and setting reminders today. Your organized workspace begins here.',
            actionLabel: 'Create First Note',
            onAction: () => context.push('/note-details/new'),
          ),
        ),
      ],
    );
  }
}

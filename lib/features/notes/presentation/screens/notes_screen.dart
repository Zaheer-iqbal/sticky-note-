import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/providers/note_provider.dart';
import 'package:sticky_notes/shared/utils/enums.dart';
import 'package:sticky_notes/shared/widgets/category_selector.dart';
import 'package:sticky_notes/core/constants/note_colors.dart';
import 'package:sticky_notes/shared/widgets/empty_state.dart';
import 'package:sticky_notes/shared/widgets/note_card.dart';
import 'package:sticky_notes/shared/widgets/note_form_dialog.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _selectedCategory = 'all';

  void _showCreateDialog() async {
    final result = await showDialog<NoteModel>(
      context: context,
      builder: (_) => const NoteFormDialog(),
    );
    if (result != null) {
      ref.read(noteNotifierProvider.notifier).addNote(result);
    }
  }

  void _showEditDialog(NoteModel note) async {
    final result = await showDialog<NoteModel>(
      context: context,
      builder: (_) => NoteFormDialog(note: note),
    );
    if (result != null) {
      ref.read(noteNotifierProvider.notifier).updateNote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteAlert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, notesAsync),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'All',
                    icon: Icons.all_inclusive,
                    isSelected: _selectedCategory == 'all',
                    onTap: () => setState(() => _selectedCategory = 'all'),
                  ),
                  ...NoteCategory.values.map(
                    (cat) => _CategoryChip(
                      label: cat.label,
                      icon: CategorySelector.categoryIcons[cat.label] ?? Icons.label,
                      isSelected: _selectedCategory == cat.label.toLowerCase(),
                      onTap: () =>
                          setState(() => _selectedCategory = cat.label.toLowerCase()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notes) {
                var filtered = notes;

                if (_selectedCategory != 'all') {
                  filtered = filtered
                      .where((n) => n.category == _selectedCategory)
                      .toList();
                }

                filtered.sort((a, b) {
                  if (a.isPinned && !b.isPinned) return -1;
                  if (!a.isPinned && b.isPinned) return 1;
                  return b.createdAt.compareTo(a.createdAt);
                });

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'No notes yet',
                    subtitle: 'Tap the + button to create your first note',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(noteNotifierProvider.notifier).loadNotes(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final note = filtered[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _showEditDialog(note),
                        onPin: () => ref
                            .read(noteNotifierProvider.notifier)
                            .togglePin(note.id),
                        onDelete: () =>
                            _confirmDelete(context, note),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(noteNotifierProvider.notifier).deleteNote(note.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, AsyncValue<List<NoteModel>> notesAsync) {
    showSearch(
      context: context,
      delegate: _NoteSearchDelegate(
        notesAsync: notesAsync,
        onNoteTap: _showEditDialog,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFFFC107).withAlpha(51),
      ),
    );
  }
}

class _NoteSearchDelegate extends SearchDelegate<String?> {
  final AsyncValue<List<NoteModel>> notesAsync;
  final Function(NoteModel) onNoteTap;

  _NoteSearchDelegate({
    required this.notesAsync,
    required this.onNoteTap,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Widget _buildSearchList(BuildContext context) {
    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        final q = query.toLowerCase();
        final results = notes
            .where((n) =>
                n.title.toLowerCase().contains(q) ||
                n.description.toLowerCase().contains(q))
            .toList();

        if (results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No results',
            subtitle: 'Try a different search term',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: NoteColors.fromName(note.colorName),
                  child: const Icon(Icons.sticky_note_2, size: 18),
                ),
                title: Text(note.title),
                subtitle: Text(
                  note.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  close(context, null);
                  onNoteTap(note);
                },
              ),
            );
          },
        );
      },
    );
  }
}

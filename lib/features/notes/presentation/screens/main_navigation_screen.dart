import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_notes/features/notes/presentation/screens/notes_screen.dart';
import 'package:sticky_notes/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:sticky_notes/features/settings/presentation/screens/settings_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(currentTabProvider);

    final List<Widget> screens = [
      const NotesScreen(),
      const RemindersScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F172A)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 0,
                ),
                _NavBarItem(
                  icon: Icons.notifications_rounded,
                  label: 'Reminders',
                  isSelected: selectedIndex == 1,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 1,
                ),
                _NavBarItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () => ref.read(currentTabProvider.notifier).state = 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

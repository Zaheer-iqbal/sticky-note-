import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticky_notes/features/notes/presentation/screens/notes_screen.dart';
import 'package:sticky_notes/features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((ref, navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

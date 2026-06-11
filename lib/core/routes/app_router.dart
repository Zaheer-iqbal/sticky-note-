import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticky_notes/core/models/note_model.dart';
import 'package:sticky_notes/features/notes/presentation/screens/main_navigation_screen.dart';
import 'package:sticky_notes/features/notes/presentation/screens/note_details_screen.dart';
import 'package:sticky_notes/features/notes/presentation/screens/splash_screen.dart';
import 'package:sticky_notes/features/reminders/presentation/screens/full_screen_reminder.dart';

final appRouterProvider = Provider.family<GoRouter, GlobalKey<NavigatorState>>((ref, navigatorKey) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/note-details/:id',
        name: 'note-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final note = state.extra as NoteModel?;
          return NoteDetailsScreen(noteId: id, initialNote: note);
        },
      ),
      GoRoute(
        path: '/reminder-alert',
        name: 'reminder-alert',
        builder: (context, state) {
          final note = state.extra as NoteModel;
          return FullScreenReminder(note: note);
        },
      ),
    ],
  );
});

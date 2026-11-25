import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memosyne/features/notes/presentation/editor/note_editor_page.dart';
import 'package:memosyne/features/notes/presentation/notes_page.dart';
import 'package:memosyne/shared/widgets/blank_page.dart';
import 'package:memosyne/shared/widgets/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tabs (shell): 0 = Bot, 1 = Calendar (home), 2 = Notes.
/// Full-screen pages (no bottom bar): note editor, search.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/calendar',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/bot', builder: (context, state) => const BlankPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const BlankPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              builder: (context, state) => const NotesPage(),
            ),
          ],
        ),
      ],
    ),
    // '/note/new' (optional ?folder=3) creates a note; '/note/12' edits note 12.
    GoRoute(
      path: '/note/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        final folder = int.tryParse(state.uri.queryParameters['folder'] ?? '');
        return NoteEditorPage(noteId: id, initialFolderId: folder);
      },
    ),
    // Blank for now (Phase 3: search and filter).
    GoRoute(
      path: '/search/notes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BlankPage(showBack: true),
    ),
  ],
);

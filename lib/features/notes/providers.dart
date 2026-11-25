import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/database/database_provider.dart';
import 'package:memosyne/features/notes/data/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(databaseProvider)),
);

/// Which folder is shown on the Notes tab. null = "All notes".
class SelectedFolderNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? folderId) => state = folderId;
}

final selectedFolderIdProvider =
    NotifierProvider<SelectedFolderNotifier, int?>(SelectedFolderNotifier.new);

final foldersProvider = StreamProvider<List<Folder>>(
  (ref) => ref.watch(notesRepositoryProvider).watchFolders(),
);

final folderCountsProvider = StreamProvider<FolderCounts>(
  (ref) => ref.watch(notesRepositoryProvider).watchCounts(),
);

final notesProvider = StreamProvider.autoDispose.family<List<Note>, int?>(
  (ref, folderId) => ref.watch(notesRepositoryProvider).watchNotes(folderId),
);

final noteByIdProvider = FutureProvider.autoDispose.family<Note?, int>(
  (ref, id) => ref.watch(notesRepositoryProvider).getNote(id),
);

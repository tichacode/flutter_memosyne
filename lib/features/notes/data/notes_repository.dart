import 'package:drift/drift.dart';
import 'package:memosyne/core/database/app_database.dart';
import 'package:memosyne/core/storage/image_storage.dart';

/// Thrown when a folder name already exists (case-insensitive for English letters).
class DuplicateFolderException implements Exception {
  const DuplicateFolderException();
}

class FolderCounts {
  const FolderCounts({this.total = 0, this.byFolder = const {}});

  /// Number of all notes ("All notes").
  final int total;

  /// folderId -> number of notes in that folder.
  final Map<int, int> byFolder;
}

class NotesRepository {
  NotesRepository(this._db);

  final AppDatabase _db;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  // ------------------------------------------------------------------ folders

  Stream<List<Folder>> watchFolders() {
    final query = _db.select(_db.folders)
      ..orderBy([
        (t) => OrderingTerm.asc(t.createdAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return query.watch();
  }

  Stream<FolderCounts> watchCounts() {
    return _db
        .customSelect(
          'SELECT folder_id, COUNT(*) AS c FROM notes GROUP BY folder_id',
          readsFrom: {_db.notes},
        )
        .watch()
        .map((rows) {
      var total = 0;
      final byFolder = <int, int>{};
      for (final row in rows) {
        final count = row.read<int>('c');
        total += count;
        final folderId = row.readNullable<int>('folder_id');
        if (folderId != null) byFolder[folderId] = count;
      }
      return FolderCounts(total: total, byFolder: byFolder);
    });
  }

  Future<bool> _folderNameTaken(String name, {int? exceptId}) async {
    final query = _db.select(_db.folders)
      ..where((t) => t.name.lower().equals(name.toLowerCase()));
    if (exceptId != null) {
      query.where((t) => t.id.isNotValue(exceptId));
    }
    return (await query.get()).isNotEmpty;
  }

  Future<void> addFolder(String name) async {
    final trimmed = name.trim();
    if (await _folderNameTaken(trimmed)) throw const DuplicateFolderException();
    await _db.into(_db.folders).insert(
          FoldersCompanion.insert(name: trimmed, createdAt: _now()),
        );
  }

  Future<void> renameFolder(int id, String name) async {
    final trimmed = name.trim();
    if (await _folderNameTaken(trimmed, exceptId: id)) {
      throw const DuplicateFolderException();
    }
    await (_db.update(_db.folders)..where((t) => t.id.equals(id)))
        .write(FoldersCompanion(name: Value(trimmed)));
  }

  /// Deletes the folder; its notes are NOT deleted, they just lose their folder.
  Future<void> deleteFolder(int id) {
    return _db.transaction(() async {
      await (_db.update(_db.notes)..where((t) => t.folderId.equals(id)))
          .write(const NotesCompanion(folderId: Value<int?>(null)));
      await (_db.delete(_db.folders)..where((t) => t.id.equals(id))).go();
    });
  }

  // -------------------------------------------------------------------- notes

  /// [folderId] null = all notes. Newest edited first.
  Stream<List<Note>> watchNotes(int? folderId) {
    final query = _db.select(_db.notes)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (folderId != null) {
      query.where((t) => t.folderId.equals(folderId));
    }
    return query.watch();
  }

  Future<Note?> getNote(int id) {
    return (_db.select(_db.notes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> createNote({
    int? folderId,
    required String title,
    required String contentJson,
    required String contentText,
  }) {
    final now = _now();
    return _db.into(_db.notes).insert(
          NotesCompanion.insert(
            folderId: Value(folderId),
            title: Value(title),
            contentJson: Value(contentJson),
            contentText: Value(contentText),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> updateNote(
    int id, {
    required String title,
    required String contentJson,
    required String contentText,
  }) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        title: Value(title),
        contentJson: Value(contentJson),
        contentText: Value(contentText),
        updatedAt: Value(_now()),
      ),
    );
  }

  /// Deletes notes and their picture files.
  Future<void> deleteNotes(List<int> ids) async {
    if (ids.isEmpty) return;
    final images = await (_db.select(_db.noteImages)
          ..where((t) => t.noteId.isIn(ids)))
        .get();
    await _db.transaction(() async {
      await (_db.delete(_db.noteImages)..where((t) => t.noteId.isIn(ids))).go();
      await (_db.delete(_db.notes)..where((t) => t.id.isIn(ids))).go();
    });
    for (final image in images) {
      await ImageStorage.deleteFile(image.filePath);
    }
  }


  /// Moves notes to a folder. [folderId] null = no folder.
  /// Does not change the "last edited" time.
  Future<void> moveNotes(List<int> ids, int? folderId) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.notes)..where((t) => t.id.isIn(ids)))
        .write(NotesCompanion(folderId: Value<int?>(folderId)));
  }

  // ------------------------------------------------------------------- images

  /// Makes sure every picture used in the note has a row in note_images.
  Future<void> syncImages(int noteId, Set<String> referenced) async {
    final rows = await (_db.select(_db.noteImages)
          ..where((t) => t.noteId.equals(noteId)))
        .get();
    final known = rows.map((r) => r.filePath).toSet();
    for (final path in referenced.difference(known)) {
      await _db.into(_db.noteImages).insert(
            NoteImagesCompanion.insert(
              noteId: noteId,
              filePath: path,
              createdAt: _now(),
            ),
          );
    }
  }

  /// Deletes rows and files of pictures that are no longer used in the note.
  Future<void> pruneImages(int noteId, Set<String> referenced) async {
    final rows = await (_db.select(_db.noteImages)
          ..where((t) => t.noteId.equals(noteId)))
        .get();
    for (final row in rows) {
      if (referenced.contains(row.filePath)) continue;
      await (_db.delete(_db.noteImages)..where((t) => t.id.equals(row.id)))
          .go();
      await ImageStorage.deleteFile(row.filePath);
    }
  }
}

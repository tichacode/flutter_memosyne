import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Phase 1 tables (notes). Task tables arrive in Phase 2 as migration v2.
// Timestamps are Unix epoch milliseconds (UTC), see memosyne_schema_draft.sql.
// ---------------------------------------------------------------------------

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
  IntColumn get createdAt => integer()();
}

@TableIndex(name: 'idx_notes_folder', columns: {#folderId})
@TableIndex(name: 'idx_notes_updated', columns: {#updatedAt})
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// null = not in any folder ("Others"). Deleting a folder sets this to null.
  IntColumn get folderId => integer()
      .nullable()
      .references(Folders, #id, onDelete: KeyAction.setNull)();

  TextColumn get title => text().withDefault(const Constant(''))();

  /// flutter_quill Delta JSON. An empty document is '[{"insert":"\n"}]'.
  TextColumn get contentJson =>
      text().withDefault(const Constant('[{"insert":"\\n"}]'))();

  /// Plain-text copy used for card previews and (later) search.
  TextColumn get contentText => text().withDefault(const Constant(''))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@TableIndex(name: 'idx_note_images_note', columns: {#noteId})
class NoteImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();

  /// Path relative to the app documents directory, e.g. 'images/123.jpg'.
  TextColumn get filePath => text()();
  IntColumn get createdAt => integer()();
}

@DriftDatabase(tables: [Folders, Notes, NoteImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'memosyne'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Phase 2: onUpgrade: (m, from, to) async { if (from < 2) { ... } },
        beforeOpen: (details) async {
          // Must run on every connection, otherwise ON DELETE rules do nothing.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

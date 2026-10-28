import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const _createIndexUpdated =
    'CREATE INDEX IF NOT EXISTS idx_notes_updated ON notes(updated_at DESC)';
const _createIndexDirty =
    'CREATE INDEX IF NOT EXISTS idx_notes_dirty ON notes(dirty)';

Future<Database> openNotesDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'offline_notes.db'),
    version: 2,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
      await db.execute(_createIndexUpdated);
      await db.execute(_createIndexDirty);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(_createIndexUpdated);
        await db.execute(_createIndexDirty);
      }
    },
  );
}

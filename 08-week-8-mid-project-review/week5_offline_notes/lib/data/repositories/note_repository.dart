import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db
        .rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  /// Id semua catatan yang belum tersinkron. Dipanggil di awal sync
  /// agar hanya catatan inilah yang nanti ditandai tersinkron.
  Future<List<int>> dirtyIds() async {
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      columns: ['id'],
      where: 'dirty = 1',
    );
    return rows.map((r) => (r['id'] as num).toInt()).toList();
  }

  /// Menandai hanya id yang diberikan sebagai tersinkron. Catatan yang
  /// dibuat selama proses sync berlangsung tetap dirty.
  Future<void> markSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await _openDb();
    final marks = List.filled(ids.length, '?').join(',');
    await db.update(
      'notes',
      {'dirty': 0},
      where: 'id IN ($marks)',
      whereArgs: ids,
    );
  }

  @Deprecated('Pakai dirtyIds() + markSynced(ids) agar aman dari race.')
  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
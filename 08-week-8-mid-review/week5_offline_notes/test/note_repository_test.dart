import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late NoteRepository repo;

  setUp(() async {
    // Database in-memory baru untuk setiap test, skemanya sama dengan db.dart
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE notes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              body TEXT NOT NULL DEFAULT '',
              updated_at TEXT NOT NULL,
              dirty INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      ),
    );
    repo = NoteRepository(openDb: () async => db);
  });

  tearDown(() async => db.close());

  test('addNote menyimpan catatan dengan dirty = true', () async {
    final note = await repo.addNote(title: 'Tugas', body: 'PemMes');

    expect(note.id, isNotNull);
    expect(note.dirty, isTrue);
    expect(await repo.countDirty(), 1);
  });

  test('fetchNotes mengurutkan dari updated_at terbaru', () async {
    await repo.addNote(title: 'Pertama');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await repo.addNote(title: 'Kedua');

    final notes = await repo.fetchNotes();

    expect(notes.map((n) => n.title), ['Kedua', 'Pertama']);
  });

  test('deleteNote menghapus catatan', () async {
    final note = await repo.addNote(title: 'Hapus saya');

    await repo.deleteNote(note.id!);

    expect(await repo.fetchNotes(), isEmpty);
    expect(await repo.countDirty(), 0);
  });

  test('markSynced hanya menandai id yang diberikan', () async {
    final a = await repo.addNote(title: 'A');
    final b = await repo.addNote(title: 'B');

    await repo.markSynced([a.id!]);

    expect(await repo.dirtyIds(), [b.id]);
    expect(await repo.countDirty(), 1);
  });

  test('catatan baru setelah dirtyIds() tetap dirty (tidak ada race)', () async {
    await repo.addNote(title: 'Lama');
    final ids = await repo.dirtyIds(); // awal sync
    final baru = await repo.addNote(title: 'Dibuat saat sync berjalan');

    await repo.markSynced(ids); // akhir sync

    expect(await repo.dirtyIds(), [baru.id]);
  });

  test('syncNotes mengembalikan jumlah dan mengosongkan antrean', () async {
    await repo.addNote(title: 'A');
    await repo.addNote(title: 'B');

    final n = await syncNotes(repo);

    expect(n, 2);
    expect(await repo.countDirty(), 0);
  });

  test('syncNotes mengembalikan 0 bila tidak ada catatan dirty', () async {
    expect(await syncNotes(repo), 0);
  });
}
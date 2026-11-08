import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/domain/note.dart';
import 'package:notes_app/features/notes/presentation/providers/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/providers/notes_search_provider.dart';
import 'package:notes_app/features/notes/presentation/widgets/notes_page.dart';

class FakeNotes extends NotesNotifier {
  FakeNotes(this.data);
  final List<Note> data;
  @override
  Future<List<Note>> build() async => data;
}

ProviderContainer makeContainer(List<Note> data) => ProviderContainer(
    overrides: [notesProvider.overrideWith(() => FakeNotes(data))]);

void main() {
  final data = [
    const Note(id: 1, title: 'Belanja Bulanan'),
    const Note(id: 2, title: 'Meeting Flutter'),
  ];

  group('3 Test Case Resmi (Prompt 5 Slot Claude)', () {
    test('1. filter case-insensitive berdasarkan judul', () async {
      final c = makeContainer(data);
      addTearDown(c.dispose);
      await c.read(notesProvider.future);
      c.read(notesQueryProvider.notifier).set('  FLUTTER ');
      final r = c.read(filteredNotesProvider).value!;
      expect(r.map((n) => n.title), ['Meeting Flutter']);
    });

    test('2. query kosong mengembalikan semua notes', () async {
      final c = makeContainer(data);
      addTearDown(c.dispose);
      await c.read(notesProvider.future);
      expect(c.read(filteredNotesProvider).value, hasLength(2));
    });

    testWidgets('3. tampil empty state saat tidak ada hasil', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [notesProvider.overrideWith(() => FakeNotes(data))],
        child: const MaterialApp(home: NotesPage()),
      ));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'zzz');
      await t.pump(const Duration(milliseconds: 350)); // lewati debounce 300ms
      await t.pumpAndSettle();
      expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
    });
  });

  group('AI Review Challenge: Perbaikan Temuan 1 & 3', () {
    // Temuan 1: Regression Test perbaikan controller
    testWidgets('4. field dan query tetap sinkron setelah halaman dibuka ulang', (t) async {
      final container = ProviderContainer(
          overrides: [notesProvider.overrideWith(() => FakeNotes(data))]);
      addTearDown(container.dispose);

      Widget app(Widget home) => UncontrolledProviderScope(
          container: container, child: MaterialApp(home: home));

      await t.pumpWidget(app(const NotesPage()));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'zzz');
      await t.pump(const Duration(milliseconds: 350));

      await t.pumpWidget(app(const SizedBox())); // keluar halaman
      await t.pumpWidget(app(const NotesPage())); // masuk lagi
      await t.pumpAndSettle();

      final field = t.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, container.read(notesQueryProvider));
    });

    // Temuan 3.1: Test empty state saat DB kosong tanpa query
    testWidgets('5. tampil empty state "Belum ada catatan" saat DB kosong tanpa query', (t) async {
      await t.pumpWidget(ProviderScope(
        overrides: [notesProvider.overrideWith(() => FakeNotes(const []))],
        child: const MaterialApp(home: NotesPage()),
      ));
      await t.pumpAndSettle();
      expect(find.text('Belum ada catatan'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    });

    // Temuan 3.2: Test query berisi spasi saja
    test('6. query berisi spasi saja mengembalikan semua notes', () async {
      final c = makeContainer(data);
      addTearDown(c.dispose);
      await c.read(notesProvider.future);
      c.read(notesQueryProvider.notifier).set('     ');
      expect(c.read(filteredNotesProvider).value, hasLength(2));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/features/notes/domain/filter_notes_by_title.dart';
import 'package:notes_app/features/notes/domain/note.dart';
import 'package:notes_app/features/notes/presentation/providers/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/providers/notes_search_provider.dart';
import 'package:notes_app/features/notes/presentation/widgets/notes_empty_state.dart';
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
  final sampleNotes = [
    const Note(id: 1, title: 'Belanja Bulanan'),
    const Note(id: 2, title: 'Meeting Flutter'),
  ];

  group('1. Domain Use Case Murni (filterNotesByTitle)', () {
    test('Filter case-insensitive dan pembersihan spasi', () {
      final result = filterNotesByTitle(sampleNotes, '  FLUTTER  ');
      expect(result.map((n) => n.title), ['Meeting Flutter']);
    });

    test('Query kosong mengembalikan seluruh daftar catatan', () {
      final result = filterNotesByTitle(sampleNotes, '');
      expect(result, hasLength(2));
    });

    test('Query spasi putih saja mengembalikan seluruh daftar catatan', () {
      final result = filterNotesByTitle(sampleNotes, '    ');
      expect(result, hasLength(2));
    });

    test('Query yang tidak cocok menghasilkan list kosong', () {
      final result = filterNotesByTitle(sampleNotes, 'zzz');
      expect(result, isEmpty);
    });
  });

  group('2. Riverpod Provider Integration', () {
    test('filteredNotesProvider bereaksi terhadap perubahan notesQueryProvider',
        () async {
      final c = makeContainer(sampleNotes);
      addTearDown(c.dispose);
      await c.read(notesProvider.future);

      c.read(notesQueryProvider.notifier).set('belanja');
      final result = c.read(filteredNotesProvider).value!;
      expect(result.map((n) => n.title), ['Belanja Bulanan']);
    });
  });

  group('3. Widget Test: NotesEmptyState', () {
    testWidgets(
        'Tampil ikon note_add_outlined dan teks "Belum ada catatan" saat isSearching false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotesEmptyState(isSearching: false),
          ),
        ),
      );

      expect(find.text('Belum ada catatan'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    });

    testWidgets(
        'Tampil ikon search_off dan teks "Tidak ada catatan yang cocok" saat isSearching true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotesEmptyState(isSearching: true),
          ),
        ),
      );

      expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });

  group('4. Widget Test: Integrasi Search & Empty State pada NotesPage', () {
    testWidgets('Tampil empty state pencarian saat query tidak cocok',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [notesProvider.overrideWith(() => FakeNotes(sampleNotes))],
        child: const MaterialApp(home: NotesPage()),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'makanan');
      await tester.pump(const Duration(milliseconds: 350)); // debounce timer
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada catatan yang cocok'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets(
        'Sinkronisasi field dan query tetap terjaga saat halaman dibuka ulang',
        (tester) async {
      final container = ProviderContainer(
          overrides: [notesProvider.overrideWith(() => FakeNotes(sampleNotes))]);
      addTearDown(container.dispose);

      Widget app(Widget home) => UncontrolledProviderScope(
          container: container, child: MaterialApp(home: home));

      await tester.pumpWidget(app(const NotesPage()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'belanja');
      await tester.pump(const Duration(milliseconds: 350));

      // Simulasi keluar dan masuk kembali ke halaman
      await tester.pumpWidget(app(const SizedBox()));
      await tester.pumpWidget(app(const NotesPage()));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'belanja');
      expect(field.controller?.text, container.read(notesQueryProvider));
    });
  });
}


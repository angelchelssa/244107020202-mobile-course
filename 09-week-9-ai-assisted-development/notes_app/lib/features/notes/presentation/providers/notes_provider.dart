import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/note.dart';

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    // Sumber data awal dari SQLite (default mock saat inisialisasi)
    return const [
      Note(id: 1, title: 'Belanja Bulanan', content: 'Kebutuhan dapur'),
      Note(id: 2, title: 'Meeting Flutter', content: 'Diskusi arsitektur'),
    ];
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

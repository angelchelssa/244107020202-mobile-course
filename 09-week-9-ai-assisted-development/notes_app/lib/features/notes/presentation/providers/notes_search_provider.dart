import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/filter_notes_by_title.dart';
import '../../domain/note.dart';
import 'notes_provider.dart';

class NotesQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final notesQueryProvider = NotifierProvider<NotesQuery, String>(NotesQuery.new);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final q = ref.watch(notesQueryProvider);
  return ref.watch(notesProvider).whenData(
        (notes) => filterNotesByTitle(notes, q),
      );
});

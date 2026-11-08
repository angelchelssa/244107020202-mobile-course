import 'note.dart';

/// Use case murni di layer Domain untuk memfilter daftar [Note] berdasarkan judul.
/// Bersifat murni Dart (pure Dart function): tidak bergantung pada Flutter, Riverpod, SQLite, maupun Dio.
List<Note> filterNotesByTitle(List<Note> notes, String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return notes;
  return notes
      .where((note) => note.title.toLowerCase().contains(trimmed))
      .toList();
}


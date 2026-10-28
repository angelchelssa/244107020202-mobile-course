import 'repositories/note_repository.dart';

/// Mengembalikan jumlah catatan yang berhasil disinkronkan.
///
/// Id catatan dirty diambil di awal, lalu hanya id itu yang ditandai
/// tersinkron. Catatan yang dibuat selama proses sync tetap dirty.
Future<int> syncNotes(NoteRepository repo) async {
  final ids = await repo.dirtyIds();
  if (ids.isEmpty) return 0;
  await Future.delayed(const Duration(seconds: 1)); // simulasi server
  await repo.markSynced(ids);
  return ids.length;
}

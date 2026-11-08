import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'post.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';

// ---------- Catatan (SQLite) ----------

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> add(String title, String body) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
    await future;
  }
}

// Jumlah catatan dirty, ikut dihitung ulang setiap daftar catatan berubah
final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

// ---------- Posts (cache-first) ----------

final postRepositoryProvider = Provider((ref) => PostRepository());

// Toggle offline deterministik untuk demo dan testing
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.watch(postRepositoryProvider);
    final offline = ref.watch(forceOfflineProvider);
    final cached = await repo.readCached();

    if (offline) return cached; // offline: hanya cache

    if (cached.isEmpty) {
      // Pertama kali dibuka: belum ada cache, tunggu jaringan
      try {
        final fresh = await repo.fetchRemote();
        await repo.saveCache(fresh);
        return fresh;
      } catch (_) {
        return cached;
      }
    }

    _refreshInBackground(repo); // tidak di-await
    return cached; // UI langsung tampil dari cache
  }

  Future<void> _refreshInBackground(PostRepository repo) async {
    try {
      final fresh = await repo.fetchRemote();
      await repo.saveCache(fresh);
      state = AsyncData(fresh);
    } catch (_) {
      // gagal (offline/timeout): cache lama tetap dipakai
    }
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/offline_providers.dart';
import '../data/sync.dart';
import '../utils/validators.dart';
import 'posts_page.dart';
import 'settings_page.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    List<String> existingTitles,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final title = TextEditingController();
    final body = TextEditingController();
    String? titleError;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Catatan baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  errorText: titleError,
                ),
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(labelText: 'Isi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final error =
                    validateTitle(title.text) ??
                    validateTitleDuplicate(title.text, existingTitles);
                if (error != null) {
                  setDialogState(() => titleError = error);
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await ref
          .read(notesProvider.notifier)
          .add(title.text.trim(), body.text.trim());
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Catatan disimpan (belum sinkron)')),
        );
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    // Mode offline ditentukan toggle forceOffline (halaman Posts).
    if (ref.read(forceOfflineProvider)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Offline: sync ditunda')));
      return;
    }

    final n = await syncNotes(ref.read(noteRepositoryProvider));
    ref.invalidate(notesProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            n == 0
                ? 'Tidak ada catatan untuk disinkronkan'
                : '$n catatan tersinkron',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article),
            tooltip: 'Posts',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostsPage()),
            ),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: Badge(
              isLabelVisible: dirty > 0,
              label: Text('$dirty'),
              child: const Icon(Icons.sync),
            ),
            onPressed: () => _sync(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('Belum ada catatan'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final n = list[i];
                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    leading: Icon(n.dirty ? Icons.cloud_off : Icons.cloud_done),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          ref.read(notesProvider.notifier).remove(n.id!),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titles = notes.asData?.value.map((n) => n.title).toList() ?? [];

          _showAddDialog(context, ref, titles);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_search_provider.dart';
import 'notes_empty_state.dart';
import 'notes_search_field.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(filteredNotesProvider);
    final isSearching = ref.watch(notesQueryProvider).trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Catatan')),
      body: Column(
        children: [
          const NotesSearchField(),
          Expanded(
            child: notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? NotesEmptyState(isSearching: isSearching)
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final note = list[index];
                        return ListTile(
                          leading: const Icon(Icons.note),
                          title: Text(note.title),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

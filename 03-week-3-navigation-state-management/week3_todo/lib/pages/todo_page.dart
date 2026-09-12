import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca daftar yang SUDAH difilter (bukan todoListProvider langsung)
    // supaya UI otomatis mengikuti pilihan filter pengguna di AppBar.
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          PopupMenuButton<TodoFilter>(
            key: const Key('todoFilterButton'),
            tooltip: 'Filter',
            initialValue: filter,
            onSelected: (value) =>
                ref.read(todoFilterProvider.notifier).set(value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
              PopupMenuItem(value: TodoFilter.active, child: Text('Aktif')),
              PopupMenuItem(value: TodoFilter.done, child: Text('Selesai')),
            ],
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                // `todos` di sini bisa jadi hasil filter (subset/urutan beda
                // dari todoListProvider), jadi kita cari index ASLI-nya
                // dulu sebelum memanggil toggle/remove. indexOf aman karena
                // filteredTodosProvider tidak menyalin objek Todo, hanya
                // memfilter referensi yang sama.
                final originalIndex =
                    ref.read(todoListProvider).indexOf(todo);
                return TodoTile(
                  todo: todo,
                  onToggle: () => ref
                      .read(todoListProvider.notifier)
                      .toggle(originalIndex),
                  onDelete: () => ref
                      .read(todoListProvider.notifier)
                      .remove(originalIndex),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

/// Widget untuk satu baris ToDo, diekstrak dari TodoPage.
///
/// Sengaja dibuat sebagai StatelessWidget biasa (bukan ConsumerWidget) dan
/// menerima callback (`onToggle`, `onDelete`) alih-alih `WidgetRef` langsung.
/// Manfaatnya:
/// - method build() di TodoPage jadi jauh lebih pendek dan mudah dibaca.
/// - TodoTile bisa diuji dengan widget test TANPA perlu membungkusnya
///   dengan ProviderScope, karena dia tidak bergantung pada Riverpod sama
///   sekali — hanya menerima data & callback biasa.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.done,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
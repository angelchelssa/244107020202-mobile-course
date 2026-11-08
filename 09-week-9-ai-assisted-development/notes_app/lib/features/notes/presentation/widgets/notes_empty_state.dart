import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  const NotesEmptyState({super.key, required this.isSearching});
  final bool isSearching;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isSearching ? Icons.search_off : Icons.note_add_outlined,
              size: 64),
          const SizedBox(height: 12),
          Text(isSearching
              ? 'Tidak ada catatan yang cocok'
              : 'Belum ada catatan'),
        ]),
      );
}

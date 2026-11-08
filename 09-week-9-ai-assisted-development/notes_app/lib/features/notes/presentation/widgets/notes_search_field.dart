import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_search_provider.dart';

class NotesSearchField extends ConsumerStatefulWidget {
  const NotesSearchField({super.key});

  @override
  ConsumerState<NotesSearchField> createState() => _State();
}

class _State extends ConsumerState<NotesSearchField> {
  Timer? _debounce;
  late final TextEditingController _ctrl =
      TextEditingController(text: ref.read(notesQueryProvider));

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _ctrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Cari judul catatan',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 300),
                () => ref.read(notesQueryProvider.notifier).set(v));
          },
        ),
      );
}

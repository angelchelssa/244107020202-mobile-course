import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/notes/presentation/widgets/notes_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notes App - AI-Assisted Development',
        home: NotesPage(),
      ),
    ),
  );
}

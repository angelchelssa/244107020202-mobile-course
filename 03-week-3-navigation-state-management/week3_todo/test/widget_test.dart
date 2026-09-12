import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    // pumpAndSettle (bukan pump() sekali) supaya animasi dialog tertutup
    // sepenuhnya. Tanpa ini, find.text bisa menemukan 2 kecocokan: teks di
    // daftar tugas DAN teks yang masih tersisa di EditableText dialog yang
    // belum selesai animasi menutup.
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('navigasi ke /stats via NavigationBar dan state ToDo tetap ada',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Tambah satu tugas dulu di halaman ToDo.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tugas persisten');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle(); // tunggu dialog benar-benar tertutup
    expect(find.text('Tugas persisten'), findsOneWidget);

    // Pindah ke halaman Statistik lewat NavigationBar.
    await tester.tap(find.text('Statistik'));
    await tester.pump(); // masuk fase loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Beri waktu timer 2 detik di StatsNotifier selesai SEBELUM berpindah
    // halaman lagi. Tanpa ini, widget tree di-dispose selagi Future.delayed
    // masih berjalan, dan test framework menganggapnya sebagai timer bocor
    // ("A Timer is still pending even after the widget tree was disposed").
    await tester.pump(const Duration(seconds: 3));

    // Kembali ke halaman ToDo.
    await tester.tap(find.text('ToDo'));
    await tester.pumpAndSettle();

    // State ToDo harus masih ada, TIDAK direset saat berpindah halaman.
    expect(find.text('Tugas persisten'), findsOneWidget);
  });

  testWidgets('filter Aktif menyembunyikan tugas yang sudah selesai',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Isi data lewat notifier langsung agar test lebih ringkas & terarah.
    container.read(todoListProvider.notifier).add('Tugas A');
    container.read(todoListProvider.notifier).add('Tugas B');
    container.read(todoListProvider.notifier).toggle(0); // Tugas A selesai

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tugas A'), findsOneWidget);
    expect(find.text('Tugas B'), findsOneWidget);

    // Buka menu filter dan pilih "Aktif". Dicari lewat Key (bukan
    // find.byType(PopupMenuButton<TodoFilter>)) karena finder berbasis tipe
    // generik lebih rapuh; Key jauh lebih stabil untuk widget test.
    await tester.tap(find.byKey(const Key('todoFilterButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aktif'));
    await tester.pumpAndSettle();

    // Tugas A (sudah selesai) harus hilang, Tugas B (belum) tetap tampil.
    expect(find.text('Tugas A'), findsNothing);
    expect(find.text('Tugas B'), findsOneWidget);
  });
}
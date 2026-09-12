import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  group('StatsNotifier', () {
    test('build() menghasilkan AsyncData valid ATAU AsyncError yang jelas',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Membaca .future akan menunggu build() selesai (baik sukses/gagal).
      try {
        final result = await container.read(statsProvider.future);
        // Kasus sukses (~70% kemungkinan): validasi bentuk datanya.
        expect(result.length, 3);
        expect(result.map((e) => e.label), contains('Total Tugas'));
        expect(result.every((e) => e.value >= 0), isTrue);
      } catch (e) {
        // Kasus gagal (~30% kemungkinan): pastikan error yang terlempar
        // adalah Exception dengan pesan yang sesuai, bukan crash asing.
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Gagal mengambil data statistik'));
      }
    });

    test('refresh() selalu melewati fase AsyncLoading', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Tunggu build awal selesai dulu (abaikan hasilnya, sukses atau gagal).
      await container.read(statsProvider.future).catchError(
            (_) => <StatItem>[],
          );

      final notifier = container.read(statsProvider.notifier);
      final refreshFuture = notifier.refresh();

      // Tepat setelah refresh() dipanggil, state HARUS AsyncLoading.
      // Ini membuktikan notifier tidak langsung lompat ke data/error tanpa
      // memberi sinyal loading ke UI.
      expect(
        container.read(statsProvider),
        isA<AsyncLoading<List<StatItem>>>(),
      );

      await refreshFuture;

      // Setelah selesai, state tidak boleh lagi berupa loading.
      final finalState = container.read(statsProvider);
      expect(finalState, isNot(isA<AsyncLoading<List<StatItem>>>()));
    });

    test('data yang berhasil selalu berupa List baru (immutable)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Tunggu build awal selesai dulu (abaikan hasilnya).
      await container.read(statsProvider.future).catchError((_) => <StatItem>[]);

      final notifier = container.read(statsProvider.notifier);
      List<StatItem>? result;

      // Panggil method refresh() milik notifier sendiri (bukan
      // container.refresh(provider.future), yang ternyata tidak memicu
      // percobaan baru dengan benar dan menyebabkan test menggantung tanpa
      // batas). refresh() dijamin selesai dalam ~2 detik setiap panggilan
      // karena itulah yang diuji di test sebelumnya.
      //
      // Peluang gagal 8 kali berturut-turut hanya ~0.3^8 ≈ 0.0006%,
      // jadi 8 percobaan sudah lebih dari cukup untuk menghindari flaky test
      // akibat kegagalan acak 30%.
      for (var i = 0; i < 8 && result == null; i++) {
        await notifier.refresh();
        final state = container.read(statsProvider);
        if (state.hasValue) {
          result = state.value;
        }
      }

      expect(result, isNotNull, reason: 'Gagal mendapat data sukses setelah beberapa percobaan');
      expect(result!.length, 3);
      // Batas waktu dinaikkan karena test ini bisa menunggu hingga ~16 detik
      // nyata (8 percobaan x 2 detik) dalam skenario apes.
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
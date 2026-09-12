import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model sederhana untuk satu baris statistik yang ditampilkan di StatsPage.
class StatItem {
  const StatItem(this.label, this.value);
  final String label;
  final int value;
}

/// AsyncNotifier yang MENSIMULASIKAN pengambilan data statistik dari server.
///
/// Kenapa AsyncNotifier, bukan Notifier biasa?
/// Karena sumber data bersifat asinkron (network call) dan bisa gagal.
/// AsyncNotifier otomatis membungkus hasil `build()` menjadi AsyncValue
/// (loading -> data / error) tanpa kita perlu membuat 3 flag boolean manual.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() => _fetchStats();

  /// Dipanggil dari tombol "Coba lagi" di UI.
  /// 1. Set state ke AsyncLoading agar UI langsung menampilkan spinner.
  /// 2. Pakai AsyncValue.guard supaya exception dari _fetchStats otomatis
  ///    ditangkap dan diubah menjadi AsyncError, tanpa try/catch manual
  ///    yang tersebar di banyak tempat.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }

  Future<List<StatItem>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi network

    final gagal = Random().nextDouble() < 0.3; // peluang gagal 30%
    if (gagal) {
      throw Exception('Gagal mengambil data statistik dari server');
    }

    // Data baru selalu dibuat sebagai List baru (immutable), bukan
    // memodifikasi list lama, supaya Riverpod bisa mendeteksi perubahan.
    return const [
      StatItem('Total Tugas', 12),
      StatItem('Tugas Selesai', 7),
      StatItem('Tugas Aktif', 5),
    ];
  }
}

/// Provider dideklarasikan dengan tipe eksplisit
/// `AsyncNotifierProvider<StatsNotifier, List<StatItem>>` agar type-safe
/// dan tidak duplikat/ambigu dengan provider lain di aplikasi.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman statistik yang menampilkan ketiga kemungkinan state dari
/// [statsProvider]: loading (spinner), error (pesan + tombol retry),
/// dan success (ListView berisi 3 item statistik).
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch DI DALAM build -> widget rebuild otomatis setiap kali
    // statsProvider berubah state (loading -> data / error).
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // `when` memaksa kita menangani ketiga cabang state secara eksplisit,
      // jadi tidak mungkin lupa menangani error (tidak ada layar putih).
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Gagal memuat: $err', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                // ref.read DI DALAM callback -> hanya memanggil method
                // sekali saat ditekan, TIDAK berlangganan perubahan state
                // (kalau pakai ref.watch di sini, salah dan boros rebuild).
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(item.label),
              trailing: Text(
                '${item.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
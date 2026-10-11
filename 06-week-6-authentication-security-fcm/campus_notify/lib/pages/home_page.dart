import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Kasus terminated: proses deep link setelah frame pertama tampil.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) consumePendingDeepLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anda sudah login'),
            const SizedBox(height: 8),
            ref.watch(accessTokenProvider).when(
                  data: (t) {
                    final shown = t == null
                        ? '-'
                        : '${t.substring(0, t.length < 12 ? t.length : 12)}...';
                    return Text('Access token: $shown');
                  },
                  loading: () => const Text('Access token: -'),
                  error: (_, _) => const Text('Access token: -'),
                ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/pengumuman/3'),
              child: const Text('Buka pengumuman #3'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/debug'),
              child: const Text('Debug FCM'),
            ),
          ],
        ),
      ),
    );
  }
}
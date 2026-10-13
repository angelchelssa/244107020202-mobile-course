import 'package:flutter/material.dart';

import '../messaging/push_service.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  String _short(String? t) {
    if (t == null) return '(belum ada)';
    return '${t.substring(0, t.length < 12 ? t.length : 12)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug FCM')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: fcmToken,
              builder: (_, t, _) => Text('FCM token: ${_short(t)}'),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: tokenSyncCount,
              builder: (_, n, _) =>
                  Text('Token dikirim ke backend: $n kali'),
            ),
            const SizedBox(height: 8),
            const Text('Topik: pengumuman-kampus'),
          ],
        ),
      ),
    );
  }
}
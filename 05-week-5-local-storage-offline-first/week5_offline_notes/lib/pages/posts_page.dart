import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/offline_providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          const Text('Offline'),
          Switch(
            value: offline,
            onChanged: (v) => ref.read(forceOfflineProvider.notifier).set(v),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade200,
              padding: const EdgeInsets.all(8),
              child: const Text('Mode offline: data dari cache lokal',
                  style: TextStyle(color: Colors.black)),
            ),
          Expanded(
            child: posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Cache kosong. Nyalakan internet dulu.'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: Text('${list[i].id}'),
                        title: Text(list[i].title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(list[i].body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
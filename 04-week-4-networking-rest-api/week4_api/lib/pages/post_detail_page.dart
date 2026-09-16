import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';
import '../data/paged_posts.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coba ambil dari list yang sudah dimuat dulu (hemat request).
    final cached = ref.watch(postListProvider).value
        ?.where((p) => p.id == postId);
    final pagedCached = ref.watch(pagedPostsProvider).items
        .where((p) => p.id == postId);
    final found = (cached?.isNotEmpty ?? false)
        ? cached!.first
        : (pagedCached.isNotEmpty ? pagedCached.first : null);

    if (found != null) {
      return _DetailScaffold(post: found);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: FutureBuilder<Post>(
        future: ref.read(postRepositoryProvider).fetchPosts().then(
              (posts) => posts.firstWhere((p) => p.id == postId),
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(friendlyErrorMessage(snapshot.error!)));
          }
          return _DetailScaffold(post: snapshot.data!, embedded: true);
        },
      ),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.post, this.embedded = false});
  final Post post;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(post.body),
        ],
      ),
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: body,
    );
  }
}
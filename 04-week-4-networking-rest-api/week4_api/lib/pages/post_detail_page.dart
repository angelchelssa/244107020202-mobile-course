import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/paged_posts.dart';
import '../data/repositories/post_repository.dart';
import '../data/api_client.dart';
import '../data/network_errors.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  Post? _post;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _resolvePost();
  }

  Future<void> _resolvePost() async {
    // 1. Coba ambil dari state list yang sudah dimuat (hindari request ulang)
    final cached = ref
        .read(pagedPostsProvider)
        .items
        .where((p) => p.id == widget.postId);

    if (cached.isNotEmpty) {
      setState(() => _post = cached.first);
      return;
    }

    // 2. Kalau tidak ada (misal halaman dibuka langsung via deep link),
    //    ambil langsung dari repository.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = PostRepository(createDio());
      final posts = await repository.fetchPosts();
      final found = posts.where((p) => p.id == widget.postId);

      setState(() {
        _post = found.isNotEmpty ? found.first : null;
        _isLoading = false;
        if (_post == null) {
          _errorMessage = 'Post tidak ditemukan.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = friendlyErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _resolvePost,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final post = _post;
    if (post == null) {
      return const Center(child: Text('Post tidak ditemukan.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(post.body, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
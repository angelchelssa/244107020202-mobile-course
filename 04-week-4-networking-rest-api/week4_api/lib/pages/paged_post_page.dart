import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isCheckingScrollable = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _tryLoadNextPage();
    }
  }

  void _tryLoadNextPage() {
    final state = ref.read(pagedPostsProvider);
    if (!state.isLoading && state.hasNextPage) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    }
  }

  // Fix untuk kasus portrait: kalau list belum overflow (maxScrollExtent == 0)
  // tapi masih ada halaman berikutnya, paksa load lagi — karena listener scroll
  // normal gak akan pernah ke-trigger selama konten belum cukup tinggi.
  // Guard `_isCheckingScrollable` mencegah pengecekan ini numpuk/beruntun
  // sebelum layout sempat settle, jadi loadingnya satu halaman per siklus,
  // gak loncat jauh (mis. langsung ke item 11+) dalam sekali render.
  void _maybeLoadMoreIfNotScrollable() {
    if (_isCheckingScrollable) return;
    _isCheckingScrollable = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isCheckingScrollable = false;

      if (!mounted || !_scrollController.hasClients) return;

      final state = ref.read(pagedPostsProvider);
      final notScrollable = _scrollController.position.maxScrollExtent == 0;

      if (notScrollable && state.hasNextPage && !state.isLoading) {
        await ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    _maybeLoadMoreIfNotScrollable();

    return Scaffold(
      appBar: AppBar(title: const Text('Posts Paged')),
      body: state.items.isEmpty && state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(pagedPostsProvider.notifier).refresh(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final post = state.items[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/paged_posts.dart';
import '../data/network_errors.dart';
import 'widgets/post_tile.dart';

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
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PagedPostsState state) {
    // State: loading pertama kali (belum ada data sama sekali)
    if (state.items.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // State: error pas pertama kali load (belum ada data buat ditampilin)
    if (state.items.isEmpty && state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                friendlyErrorMessage(state.error!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(pagedPostsProvider.notifier).loadNextPage(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // State: empty (request sukses tapi datanya kosong)
    if (state.items.isEmpty && !state.isLoading) {
      return const Center(child: Text('Belum ada data.'));
    }

    // State: success (list data, mungkin masih loading halaman berikutnya)
    return RefreshIndicator(
      onRefresh: () => ref.read(pagedPostsProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.items.length + 1, // +1 buat footer
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _buildFooter(state);
          }

          final post = state.items[index];
          return PostTile(
            post: post,
            index: index,
            onTap: () => context.push('/post/${post.id}'),
          );
        },
      ),
    );
  }

  Widget _buildFooter(PagedPostsState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      // Gagal load halaman berikutnya (data lama tetap ada), kasih retry kecil
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              friendlyErrorMessage(state.error!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(pagedPostsProvider.notifier).loadNextPage(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (!state.hasNextPage) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Semua data sudah dimuat')),
      );
    }

    return const SizedBox.shrink();
  }
}
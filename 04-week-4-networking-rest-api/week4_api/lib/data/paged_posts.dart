import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/post.dart';

class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.currentPage = 0,
    this.hasNextPage = true,
    this.isLoading = false,
    this.error,
  });

  final List<Post> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoading;
  final Object? error;

  PagedPostsState copyWith({
    List<Post>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return PagedPostsState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  static const int _pageSize = 10;

  @override
  PagedPostsState build() {
    return const PagedPostsState();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasNextPage) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final dio = ref.read(dioProvider);
      final nextPage = state.currentPage + 1;

      final response = await dio.get<List>(
        '/posts',
        queryParameters: {
          '_page': nextPage,
          '_limit': _pageSize,
        },
      );

      final data = response.data ?? [];
      final newPosts = data
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList();

      state = state.copyWith(
        items: [...state.items, ...newPosts],
        currentPage: nextPage,
        hasNextPage: newPosts.length == _pageSize,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = const PagedPostsState();
    await loadNextPage();
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
  PagedPostsNotifier.new,
);

final dioProvider = Provider((ref) => createDio());
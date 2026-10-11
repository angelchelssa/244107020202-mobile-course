import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepositoryImpl();
});

final dioProvider = Provider<Dio>((ref) => buildApiClient(
      ref.watch(tokenStoreProvider),
      ref.watch(authRepositoryProvider),
    ));

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

/// Provider untuk membaca access token agar widget (seperti HomePage)
/// tidak perlu memanggil TokenStore secara langsung.
final accessTokenProvider = FutureProvider<String?>((ref) async {
  return ref.watch(tokenStoreProvider).readAccess();
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(loginUseCaseProvider)(email, password);
      if (result.failure != null) {
        state = AsyncError(result.failure!.message, StackTrace.current);
        return;
      }

      if (result.session != null) {
        await ref.read(tokenStoreProvider).save(
              access: result.session!.access,
              refresh: result.session!.refresh,
            );
        state = const AsyncData(true);
      }
    } catch (e, st) {
      state = AsyncError(e.toString().replaceFirst('Exception: ', ''), st);
    }
  }

  Future<void> logout() async {
    try {
      final result = await ref.read(logoutUseCaseProvider)();
      if (result.failure != null) {
        state = AsyncError(result.failure!.message, StackTrace.current);
        return;
      }

      await ref.read(tokenStoreProvider).clear();
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e.toString().replaceFirst('Exception: ', ''), st);
    }
  }
}

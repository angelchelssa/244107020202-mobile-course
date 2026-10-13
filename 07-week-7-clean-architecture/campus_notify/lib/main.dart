import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/background_handler.dart';
import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_page.dart';
import 'pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> _initPush() async {
  await initLocalNotifications();
  await requestNotificationPermission();
  await setupMessageHandlers();
  await initFcmToken(
    onToken: (token) async {
      fcmToken.value = token;
      debugPrint('FULL_TOKEN=$token');
      final shown = token.length < 12 ? token : token.substring(0, 12);
      debugPrint('[MOCK] token dikirim ke backend ($shown...)');
      tokenSyncCount.value++;
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initPush();
  } catch (e, st) {
    debugPrint('Gagal menginisialisasi Firebase/Notifikasi: $e\n$st');
  }

  runApp(const ProviderScope(child: MyApp()));
}

/// Provider untuk mengecek token awal saat cold start.
/// Memastikan state token sudah terbaca sebelum menentukan rute pertama,
/// sehingga tidak ada kedipan tampilan (flicker) antara HomePage dan LoginPage.
final initialAuthCheckProvider = FutureProvider<bool>((ref) async {
  final token = await ref.watch(tokenStoreProvider).readAccess();
  return token != null;
});

/// Listenable untuk memberi sinyal ke GoRouter saat state auth berubah.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Router provider dengan dukungan route guarding berdasarkan status autentikasi.
final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '-';
          return AnnouncementPage(id: id);
        },
      ),
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugPage(),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);

      // Jangan redirect saat sedang proses login (loading) agar indikator loading
      // pada tombol tetap aktif dan feedback error bisa ditampilkan dengan tepat.
      if (auth.isLoading) return null;

      final isLoggedIn = auth.asData?.value ?? false;
      final isLoggingIn = state.matchedLocation == '/login';

      // Pengguna belum login: arahkan ke /login jika mencoba akses rute terproteksi.
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Pengguna sudah login: arahkan ke halaman utama / jika masih di /login.
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
  );

  ref.onDispose(routerNotifier.dispose);
  // Simpan instance router ke service messaging untuk navigasi deep link push notification.
  appRouter = router;
  return router;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialAuth = ref.watch(initialAuthCheckProvider);

    // Tampilkan loading screen sederhana saat inisialisasi awal token dari SecureStorage.
    if (initialAuth.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

typedef CampusNotifyApp = MyApp;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/todo_page.dart';
import 'pages/stats_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

/// Konfigurasi routing dengan GoRouter.
/// '/'      -> daftar ToDo
/// '/stats' -> halaman statistik
///
/// ShellRoute dipakai supaya NavigationBar tetap tampil konsisten di kedua
/// halaman, dan yang paling penting: state ToDo (di todoListProvider) TIDAK
/// hilang saat berpindah halaman, karena ProviderScope tetap membungkus
/// seluruh MaterialApp di lapisan atas, bukan dibuat ulang per halaman.
final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 3 - ToDo',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        routerConfig: _router,
      );
}

/// Scaffold pembungkus dengan NavigationBar di bagian bawah, dipakai
/// bersama oleh semua route lewat ShellRoute.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = location.startsWith('/stats') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(index == 0 ? '/' : '/stats');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'ToDo'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Statistik'),
        ],
      ),
    );
  }
}
# Output Awal AI (Claude)

Berikut adalah draf awal kode `push_service.dart` yang dihasilkan oleh Claude sebelum dilakukan penelaahan dan perbaikan manual:

```dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

// Background handler top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // TIDAK BOLEH akses BuildContext atau ProviderScope di sini karena isolate terpisah
  print("Handling a background message: ${message.messageId}");
}

class PushService {
  final _local = FlutterLocalNotificationsPlugin();
  String? pendingDeepLink;

  Future<void> init() async {
    // 1. Request permission
    // Android 13+ (Tiramisu / API 33+) butuh runtime permission POST_NOTIFICATIONS
    // iOS butuh prompt izin pemberitahuan eksplisit
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize local notification
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      InitializationSettings(android: android, iOS: ios), // Masalah: parameter posisi pada versi lama
      onDidReceiveNotificationResponse: (response) {
        pendingDeepLink = response.payload;
      },
    );

    // 3. Token lifecycle
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });

    // 4. Topic subscription
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');

    // 5. Handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _local.show(
        message.hashCode, // Masalah: parameter posisi
        message.notification?.title ?? 'Notifikasi',
        message.notification?.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails('high_channel', 'High Channel'),
        ),
        payload: jsonEncode(message.data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      pendingDeepLink = jsonEncode(message.data);
    });

    RemoteMessage? initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      pendingDeepLink = jsonEncode(initial.data);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    // dio.post('/devices', data: {'token': token});
    print('Kirim token ke backend: $token');
  }
}
```

## Analisis Masalah pada Draf Awal

1. `_local.initialize` dan `_local.show` masih memakai signature posisi versi `flutter_local_notifications` versi terdahulu (gagal kompilasi pada versi v22+).
2. Draf tidak menyediakan callback navigasi instan untuk `onDidReceiveNotificationResponse` dan `onMessageOpenedApp`, hanya menyimpan ke variabel `pendingDeepLink` tanpa memicu GoRouter.
3. Metode `unsubscribeFromTopic` belum disediakan.
4. Fungsi `init()` menggabungkan seluruh inisialisasi yang berpotensi memblokir `runApp()` jika koneksi internet lambat.

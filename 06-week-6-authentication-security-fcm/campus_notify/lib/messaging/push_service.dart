import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

final _local = FlutterLocalNotificationsPlugin();

/// Dipakai halaman Debug.
final fcmToken = ValueNotifier<String?>(null);
final tokenSyncCount = ValueNotifier<int>(0);

/// Diisi dari tempat GoRouter dibuat.
GoRouter? appRouter;

/// Payload (JSON string) yang menunggu diproses setelah router siap.
String? pendingDeepLink;

const _channel = AndroidNotificationChannel(
  'campus_notify_high',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman kampus',
  importance: Importance.high,
);

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      // Klik banner foreground -> buka halaman sesuai payload.
      openFromPayload(response.payload);
    },
  );

  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // 1. Ambil token saat ini dan kirim ke backend.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    fcmToken.value = token;
    await onToken(token);
  }

  // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    fcmToken.value = newToken;
    onToken(newToken);
  });

  // 3. Langganan topik kampus.
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

/// Tiga kondisi app: foreground, background (klik), terminated (klik).
Future<void> setupMessageHandlers() async {
  // FOREGROUND: FCM tidak menampilkan banner sendiri, tampilkan manual.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('[FG] data=${message.data}');
    final n = message.notification;
    _local.show(
      id: message.hashCode,
      title: n?.title ?? 'Campus Notify',
      body: n?.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  });

  // BACKGROUND: banner diketuk saat app di background.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('[BG-OPEN] data=${message.data}');
    openFromPayload(jsonEncode(message.data));
  });

  // TERMINATED: app dibuka dari keadaan mati lewat banner.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    debugPrint('[TERMINATED-OPEN] data=${initial.data}');
    pendingDeepLink = jsonEncode(initial.data);
  }
}

/// Payload: {"route": "/pengumuman/3"} atau {"id": "3"}
void openFromPayload(String? payload) {
  if (payload == null || payload.isEmpty) return;
  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final route = data['route'] as String? ??
        (data['id'] != null ? '/pengumuman/${data['id']}' : null);
    if (route == null) return;

    final router = appRouter;
    if (router == null) {
      pendingDeepLink = payload; // router belum siap
      return;
    }
    router.push(route);
  } catch (e) {
    debugPrint('Payload tidak valid: $e');
  }
}

/// Dipanggil dari HomePage setelah frame pertama (kasus terminated).
void consumePendingDeepLink() {
  final p = pendingDeepLink;
  pendingDeepLink = null;
  openFromPayload(p);
}
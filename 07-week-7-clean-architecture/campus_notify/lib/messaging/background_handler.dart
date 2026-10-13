import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// WAJIB top-level (di luar class) dan diberi entry-point pragma.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // isolate terpisah, init ulang
  debugPrint('[BG] id=${message.messageId} data=${message.data}');
}
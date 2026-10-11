# Prompt yang Digunakan (AI Challenge)

**Tool AI:** Claude

Berikut adalah prompt lengkap yang digunakan pada tugas AI Challenge untuk menghasilkan implementasi awal modul *push notification*:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## Tujuan & Ekspektasi

1. Mengamankan penanganan token FCM sesuai *lifecycle* (termasuk rotasi token dan pengiriman berkala ke backend).
2. Memastikan banner notifikasi muncul di ketiga kondisi aplikasi: *foreground*, *background*, dan *terminated*.
3. Navigasi otomatis ke rute yang dibawa oleh payload (`data.route`, misalnya `/pengumuman/3`).
4. Memisahkan *isolate* untuk background handler agar terhindar dari pemanggilan `BuildContext` atau Riverpod secara ilegal.

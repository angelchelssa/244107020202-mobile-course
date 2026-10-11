# Campus Notify (`campus_notify`)

Aplikasi mobile Flutter untuk sistem notifikasi dan pengumuman kampus. Aplikasi ini menerapkan autentikasi dengan penyimpanan token aman di platform Keystore/Keychain, refresh token otomatis lewat HTTP interceptor, route guarding deklaratif, serta integrasi **Firebase Cloud Messaging (FCM)** yang mendukung navigasi deep-link dari tiga status aplikasi (*foreground*, *background*, *terminated*) dan siaran pengumuman berbasis topik.

---

## Fitur Utama

- **Secure Token Storage**: Access token dan refresh token disimpan terenkripsi menggunakan `flutter_secure_storage` (bukan `SharedPreferences`).
- **HTTP Interceptor & Token Refresh**: Klien Dio secara otomatis menyisipkan header `Authorization: Bearer <token>` dan menangani peremajaan token saat menerima respons HTTP `401 Unauthorized`.
- **Route Guarding**: Navigasi menggunakan `go_router` yang tersinkronisasi dengan status autentikasi Riverpod (`refreshListenable`) untuk mengamankan halaman internal.
- **Push Notification Lifecycle (FCM)**:
  - **Foreground**: Menampilkan banner manual via `flutter_local_notifications`.
  - **Background**: Ditangani oleh sistem Android; ketukan membuka aplikasi via `onMessageOpenedApp`.
  - **Terminated**: Membuka rute spesifik saat aplikasi mati via `getInitialMessage()`.
  - **Topic Messaging**: Berlangganan topik siaran massal kampus (`pengumuman-kampus`).
- **Isolate Background Handler**: Handler background top-level dengan `@pragma('vm:entry-point')` yang berjalan aman di luar `BuildContext`.

---

## Struktur Direktori

```
campus_notify/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts           # Konfigurasi desugaring, minSdk 23, applicationId
│   │   ├── google-services.json       # Konfigurasi proyek Firebase (tidak di-commit)
│   │   └── src/main/AndroidManifest.xml # Izin POST_NOTIFICATIONS
│   └── settings.gradle.kts            # Plugin com.google.gms.google-services
├── lib/
│   ├── main.dart                      # Inisialisasi Firebase, GoRouter, ProviderScope
│   ├── core/
│   │   └── failures.dart              # Failure domain (AuthFailure, NetworkFailure)
│   ├── data/
│   │   └── api_client.dart            # Klien Dio + interceptor refresh token 401
│   ├── features/
│   │   └── auth/
│   │       ├── domain/                # entities, repositories (interface), usecases (login, logout)
│   │       ├── data/                  # models, repositories (impl), token_store.dart
│   │       └── presentation/          # pages/login_page.dart, providers/auth_provider.dart
│   ├── messaging/
│   │   ├── background_handler.dart    # Handler pesan FCM saat aplikasi di background
│   │   └── push_service.dart          # Izin notifikasi, listener token, handler 3 state
│   └── pages/
│       ├── announcement_page.dart     # Halaman detail pengumuman (/pengumuman/:id)
│       ├── debug_page.dart            # Halaman diagnosa token FCM & sinkronisasi
│       └── home_page.dart             # Halaman utama setelah login
└── test/
    ├── auth_repository_test.dart      # Unit test logika autentikasi & refresh
    └── widget_test.dart               # Widget smoke test cold-start LoginPage
```

> Struktur `lib/` diperbarui pada Week 7 (Clean Architecture untuk fitur auth). Detail di laporan Week 7.

---

## Prasyarat & Konfigurasi

1. **Flutter SDK**: Versi `^3.13.5` atau yang lebih baru.
2. **Android SDK**: `minSdk = 23` (diperlukan oleh `flutter_secure_storage`), Java 17, dan Core Library Desugaring aktif (`isCoreLibraryDesugaringEnabled = true`).
3. **Firebase Setup**:
   - Pastikan berkas `google-services.json` yang diunduh dari Firebase Console diletakkan di dalam folder `android/app/`.
   - Package name Android: `com.example.campus_notify`.

---

## Menjalankan Aplikasi

1. **Unduh dependensi**:
   ```bash
   flutter pub get
   ```

2. **Jalankan aplikasi (Debug mode)**:
   ```bash
   flutter run
   ```

3. **Menjalankan pengujian otomatis**:
   ```bash
   flutter test
   ```

4. **Analisis kualitas kode**:
   ```bash
   flutter analyze
   ```

---

## Kredensial Uji Coba

Aplikasi menggunakan autentikasi tiruan (*mock*) yang memvalidasi format email dan panjang sandi:
- **Email**: Harus berisi karakter `@` (contoh: `mhs@polinema.ac.id`).
- **Kata Sandi**: Minimal 6 karakter (contoh: `123456`).

---

## Tautan Terkait

- **[Laporan Praktikum Week 6 (Lengkap)](../README.md)**
- **[Dokumentasi Prompt AI](../docs/01-prompt.md)**
- **[Draf Awal AI](../docs/02-output-awal-ai.md)**
- **[Hasil Verifikasi & Perbaikan](../docs/03-hasil-verifikasi.md)**
- **[Hasil Uji Tiga App State & Topik](../docs/04-hasil-uji-tiga-state.md)**
- **[Folder Tangkapan Layar](../screenshots/)**
- **[Laporan Week 7: Clean Architecture](../../07-week-7-clean-architecture/README.md)**
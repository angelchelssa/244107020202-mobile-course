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
│   ├── data/
│   │   ├── api_client.dart            # Klien Dio + interceptor refresh token 401
│   │   ├── auth_repository.dart       # Mock login & refresh autentikasi
│   │   └── token_store.dart           # Akses tunggal penyimpanan flutter_secure_storage
│   ├── messaging/
│   │   ├── background_handler.dart    # Handler pesan FCM saat aplikasi di background
│   │   └── push_service.dart          # Izin notifikasi, listener token, handler 3 state
│   ├── pages/
│   │   ├── announcement_page.dart     # Halaman detail pengumuman (/pengumuman/:id)
│   │   ├── debug_page.dart            # Halaman diagnosa token FCM & sinkronisasi
│   │   ├── home_page.dart             # Halaman utama setelah login
│   │   └── login_page.dart            # Halaman autentikasi pengguna
│   └── providers/
│       └── auth_provider.dart         # Riverpod AsyncNotifierProvider untuk status login
└── test/
    ├── auth_repository_test.dart      # Unit test logika autentikasi & refresh
    └── widget_test.dart               # Widget smoke test cold-start LoginPage
```

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
- **Email**: Harus berisi karakter `@` (contoh: `mahasiswa@campus.ac.id`).
- **Kata Sandi**: Minimal 6 karakter (contoh: `admin123`).

---

## Tautan Terkait

- **[Laporan Praktikum Week 6 (Lengkap)](../README.md)**
- **[Dokumentasi Prompt AI](../docs/01-prompt.md)**
- **[Draf Awal AI](../docs/02-output-awal-ai.md)**
- **[Hasil Verifikasi & Perbaikan](../docs/03-hasil-verifikasi.md)**
- **[Hasil Uji Tiga App State & Topik](../docs/04-hasil-uji-tiga-state.md)**
- **[Folder Tangkapan Layar](../screenshots/)**


---


## PRAKTIKUM 1: AUDIT LAYER PROJECT campus_notify

Snapshot sebelum refactor: commit `chore: snapshot before clean architecture`.

### 1. Pemetaan file ke layer

| File | Layer saat ini | Masalah |
|---|---|---|
| `main.dart` | Bootstrap + presentation | Routing (GoRouter), guard auth, dan init push disatukan; `initialAuthCheckProvider` mengakses `TokenStore` langsung; router disimpan di variabel global |
| `data/api_client.dart` | data | `Dio(BaseOptions(...))` dibuat manual dengan base URL hardcode (baris 6); bergantung pada kelas konkret `TokenStore` dan `AuthRepository` |
| `data/auth_repository.dart` | data (kontrak tercampur) | Interface dan implementasi masih satu kelas; model `AuthSession` belum dipisah dari entity |
| `data/token_store.dart` | data (local datasource) | Tanpa abstraksi; `FlutterSecureStorage()` dibuat langsung di constructor |
| `messaging/background_handler.dart` | infrastruktur | Belum masuk struktur `core/` |
| `messaging/push_service.dart` | infrastruktur + presentation | Memakai variabel global (`fcmToken`, `tokenSyncCount`, `pendingDeepLink`, `appRouter`); memanggil navigasi UI langsung; `jsonDecode`/`jsonEncode` tanpa model |
| `pages/announcement_page.dart` | presentation | Baru menampilkan ID dari route, belum terhubung ke state/use case |
| `pages/debug_page.dart` | presentation | Membaca variabel global `ValueNotifier` dari `push_service.dart`, bukan lewat provider |
| `pages/home_page.dart` | presentation | Baris 44: memanggil `tokenStoreProvider.readAccess()` langsung di `build()` |
| `pages/login_page.dart` | presentation | Baris 49: `replaceFirst('Exception: ', '')` di `build()`; belum memakai `Failure` |
| `providers/auth_provider.dart` | presentation (state) | Baris 11: `AuthRepository()` dibuat manual; notifier memanggil repository dan `TokenStore` tanpa use case |

### 2. Hasil pencarian pelanggaran

| Pencarian | Hasil |
|---|---|
| Widget menyentuh jaringan/database langsung (`lib/pages`) | 0 temuan |
| Logika bisnis di `build()`: `DateFormat`, `jsonDecode`, `toIso8601String` (`lib/pages`) | 0 temuan |
| Instansiasi manual: `Repository(`, `Dio(BaseOptions` (`lib/pages`, `lib/providers`) | 1 temuan: `lib/providers/auth_provider.dart:11` |

Catatan: folder `lib/widgets` tidak ada di project ini.

### 3. Daftar item refactor

1. `providers/auth_provider.dart:11`: `AuthRepository()` dibuat manual. Perbaikan: buat interface `AuthRepository` di domain, `AuthRepositoryImpl` di data, lalu suntik lewat provider.
2. `pages/home_page.dart:44`: widget membaca token store langsung. Perbaikan: ambil token lewat state/provider auth, bukan dari widget. (Tidak tertangkap `rg`, ditemukan lewat pembacaan manual.)
3. `data/auth_repository.dart`: interface dan implementasi satu kelas. Perbaikan: pisahkan kontrak dan implementasi.
4. `data/api_client.dart:6`: `Dio` hardcode di data layer. Perbaikan: sediakan lewat provider di `core/providers.dart`.
5. `pages/login_page.dart:49`: format error di `build()`. Perbaikan: petakan ke `Failure` di `core/failures.dart`.
6. `messaging/push_service.dart`: variabel global dan navigasi langsung. Perbaikan: ubah bertahap bila waktu cukup (di luar target utama).

Target setelah Praktikum 3: ketiga pencarian menghasilkan **0 temuan** di folder presentation.

### 4. Struktur target (fitur: auth)

```text
lib/
├── core/
│   ├── failures.dart
│   └── providers.dart
├── features/
│   └── auth/
│       ├── domain/
│       │   ├── entities/auth_session.dart
│       │   ├── repositories/auth_repository.dart   # interface
│       │   └── usecases/
│       │       ├── login.dart
│       │       └── logout.dart
│       ├── data/
│       │   ├── models/auth_session_model.dart
│       │   ├── token_store.dart
│       │   └── repositories/auth_repository_impl.dart
│       └── presentation/
│           ├── providers/auth_provider.dart
│           └── pages/login_page.dart
└── routes.dart
```
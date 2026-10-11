# Output awal usulan AI Assistant

Draf usulan arsitektur awal yang dihasilkan oleh AI Assistant berdasarkan prompt yang diajukan:

---

## 1. Usulan Struktur Folder Feature-First Clean Architecture

```text
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   └── routing/
│       └── app_router.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_session.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart       # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       ├── logout.dart
│   │   │       └── refresh_token.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart # TokenStore
│   │   │   ├── models/
│   │   │   │   └── auth_session_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart  # Concrete implementation
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   └── announcements/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── announcement.dart
│       │   ├── repositories/
│       │   │   └── announcement_repository.dart
│       │   └── usecases/
│       │       ├── get_announcements.dart
│       │       └── get_announcement_by_id.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   └── announcement_remote_data_source.dart
│       │   ├── models/
│       │   │   └── announcement_model.dart
│       │   └── repositories/
│       │       └── announcement_repository_impl.dart
│       └── presentation/
│           ├── pages/
│           │   ├── announcement_list_page.dart
│           │   └── announcement_detail_page.dart
│           └── providers/
│               └── announcement_provider.dart
└── main.dart
```

---

## 2. Pemetaan File Lama (Tujuan Baru)

| File Lama | Status Usulan AI | Lokasi / Tujuan Baru |
|---|---|---|
| `lib/data/api_client.dart` | Pindah | `lib/core/network/api_client.dart` |
| `lib/data/auth_repository.dart` | Pecah | Kontrak: `features/auth/domain/repositories/auth_repository.dart`<br>Implementasi: `features/auth/data/repositories/auth_repository_impl.dart` |
| `lib/data/token_store.dart` | Pindah | `features/auth/data/datasources/auth_local_data_source.dart` |
| `lib/providers/auth_provider.dart` | Pecah / Refactor | `features/auth/presentation/providers/auth_provider.dart` (hanya UI state & wiring) |
| `lib/pages/login_page.dart` | Pindah | `features/auth/presentation/pages/login_page.dart` |
| `lib/pages/home_page.dart` | Pindah | `lib/features/home/presentation/pages/home_page.dart` atau tetap di `lib/pages/` |
| `lib/pages/announcement_page.dart` | Pindah / Pecah | `features/announcements/presentation/pages/` |
| `lib/pages/debug_page.dart` | Pindah | Tetap di `lib/pages/` atau `core/debug/` |
| `lib/messaging/*` | Pindah | `lib/core/messaging/` atau `lib/features/notifications/` |

---

## 3. Identifikasi Over-Engineering & Kapan Use Case Dibutuhkan

### Usulan AI:
1. **Bagian yang Over-Engineering:**
   - Membuat use case terpisah untuk setiap query CRUD sederhana (misal: `GetAnnouncementById`, `GetAnnouncements`) yang hanya meneruskan satu baris pemanggilan dari repository:
     ```dart
     // Contoh 1-line use case yang over-engineering untuk CRUD biasa
     class GetAnnouncementById {
       final AnnouncementRepository repo;
       GetAnnouncementById(this.repo);
       Future<Announcement> call(String id) => repo.getById(id);
     }
     ```
   - Memecah data source menjadi `RemoteDataSource` dan `LocalDataSource` interfaces yang terpisah padahal belum ada caching lokal di database (SQLite).
2. **Kapan Use Case Benar-Benar Dibutuhkan:**
   - Terdapat **aturan bisnis (business rules)** yang perlu dieksekusi sebelum/sesudah memanggil repository (misal: validasi input, sanitasi, hashing, atau pengecekan kuota percobaan).
   - Terdapat **orkestrasi multi-repository** (misal: use case `LoginAndSyncDevice` yang memanggil `AuthRepository` lalu memanggil `DeviceRepository`).
   - Logika tersebut digunakan bersama oleh beberapa UI/notifier yang berbeda.

---

## 4. Usulan Wiring DI dengan Riverpod (Murni Tanpa Package Tambahan)

```dart
// 1. Data Source / Store Provider
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

// 2. Repository Provider (expose Interface Domain, instantiate Impl Data)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepositoryImpl();
});

// 3. Use Case Providers
final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

// 4. Presentation Notifier Provider
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
```

### Trade-off Menurut AI:
- **Keuntungan:** Dekoupling penuh, UI tidak mengenal kelas konkret data layer, mudah di-mock dalam testing tanpa `get_it`.
- **Konsekuensi:** Jumlah berkas dan boilerplate meningkat, kurva pemahaman developer lebih tinggi dibandingkan direct repository access.

# Hasil verifikasi output AI

Dokumentasi audit terhadap usulan AI Assistant, tabel perbandingan keputusan, hasil tiga grep verifikasi, dan alur dependensi untuk sesi demo.

---

## 1. Verifikasi Checklist Terhadap Usulan AI

| # | Pertanyaan verifikasi | Temuan & Status | Catatan Teknis / Argumentasi |
|:---:|---|:---:|---|
| 1 | Interface repository tinggal di domain dan implementasi di data? | Diterima | `AuthRepository` abstract diletakkan di `domain/repositories/` dan `AuthRepositoryImpl` di `data/repositories/`. Tidak disatukan di satu folder. |
| 2 | Domain bebas import Flutter / Dio / SQLite / Firebase? | Diterima | Diverifikasi via `git grep`: 0 import library luar ditemukan. Domain murni Dart (*vanilla Dart*). |
| 3 | AI membuat use case untuk tiap CRUD satu-baris? | Ditolak / Disesuaikan | AI mengusulkan use case untuk announcements (`GetAnnouncements`, `GetAnnouncementById`). Ditolak karena announcements belum memiliki alur data backend (over-engineering). Hanya diterapkan pada auth (`Login`, `Logout`). |
| 4 | Entity bebas mapping (`toMap`/`fromMap`/`toJson`)? | Diterima | Entity `AuthSession` murni tanpa method serialization. Semua serialisasi diisolasi di `AuthSessionModel` (data layer). |
| 5 | Wiring DI terpusat di provider dan widget tidak `new Repository()` sendiri? | Diterima | Terpusat di `auth_provider.dart`. Widget (`LoginPage`, `HomePage`) hanya mengonsumsi provider lewat Riverpod. |
| 6 | Keputusan final berbeda dari saran AI selama berargumen? | Diterapkan | Membatasi cakupan refactoring pada fitur `auth`. Fitur `announcements` dipertahankan di `pages/` agar tidak menambah kompleksitas tanpa manfaat fungsional. |

---

## 2. Tabel Perbandingan Usulan AI vs Keputusan Final

| Aspek Arsitektur | Usulan Awal AI | Keputusan Final | Alasan Teknis & Trade-off |
|---|---|---|---|
| **Cakupan Refactoring** | Refactor fitur `auth` dan `announcements` sekaligus ke Clean Architecture. | Hanya refactor fitur `auth`. Fitur `announcements` tetap di `pages/`. | **Menghindari Over-Engineering:** `announcements` saat ini hanya menampilkan ID dummy dari route tanpa state atau API call. Membuat lapisan data/domain untuk halaman statis menambah kompleksitas tanpa nilai tambah. |
| **Pemisahan Repository** | Interface di domain, implementasi di data. | Disetujui dan diterapkan. | Mematuhi **Dependency Inversion Principle (DIP)** dan mempermudah unit testing/mocking. |
| **Pemisahan Entity vs Model** | `AuthSession` di domain, `AuthSessionModel` di data. | Disetujui dan diterapkan. | Domain tidak terikat dengan format serialisasi JSON backend. |
| **Use Cases pada Auth** | Buat `Login`, `Logout`, `RefreshToken`. | Buat `Login` dan `Logout`. Refresh token ditangani di interceptor. | `Login` dan `Logout` menjadi titik masuk aturan bisnis (validasi, batas percobaan). Refresh token lebih tepat di level networking. |
| **Error Handling** | Exception mentah atau Dartz `Either`. | `sealed class Failure` dan Dart Record `({T? session, Failure? failure})`. | Menggunakan fitur bawaan Dart 3 tanpa ketergantungan package eksternal (`dartz`/`fpdart`). |
| **Wiring DI** | Riverpod Provider murni. | Disetujui dan diterapkan. | Zero-dependency DI, aman secara tipe (*compile-time safe*), dan mudah di-override pada unit/widget test. |

---

## 3. Hasil Tiga Grep Verifikasi Mandiri

### Grep 1 — Memastikan Domain dan Core Bebas Dependensi Eksternal
```bash
git grep -nE "(package:flutter|package:dio|package:sqflite|package:firebase)" -- "lib/features/auth/domain" "lib/core"
```
**Hasil:**
```text
Exit code: 1 (0 temuan / bersih)
```
*Interpretasi:* Lapisan Domain dan Core 100% independen dari framework UI dan library luar.

### Grep 2 — Memastikan UI Bebas Instansiasi Manual Repository/Storage/Dio
```bash
git grep -nE "(AuthRepository|TokenStore|Dio)\(" -- "lib/features/auth/presentation/pages" "lib/pages"
```
**Hasil:**
```text
Exit code: 1 (0 temuan / bersih)
```
*Interpretasi:* Seluruh widget bersih dari instansiasi manual kelas konkret; semuanya diakses via provider Riverpod.

### Grep 3 — Memastikan Entity Bersih dari Fungsi Serialisasi (toMap/fromMap/toJson)
```bash
git grep -nE "(toMap|fromMap|toJson|fromJson)" -- "lib/features/auth/domain/entities"
```
**Hasil:**
```text
Exit code: 1 (0 temuan / bersih)
```
*Sebagai perbandingan, mapping hanya ada di Data Model:*
```bash
git grep -nE "(toMap|fromMap|toJson|fromJson)" -- "lib/features/auth/data"
```
**Output:**
```text
lib/features/auth/data/models/auth_session_model.dart:11:  factory AuthSessionModel.fromMap(Map<String, dynamic> map) {
lib/features/auth/data/models/auth_session_model.dart:18:  Map<String, dynamic> toMap() {
lib/features/auth/data/models/auth_session_model.dart:25:  factory AuthSessionModel.fromJson(String source) =>
lib/features/auth/data/models/auth_session_model.dart:26:      AuthSessionModel.fromMap(json.decode(source) as Map<String, dynamic>);
lib/features/auth/data/models/auth_session_model.dart:28:  String toJson() => json.encode(toMap());
```

---

## 4. Alur Arah Dependensi untuk Presentasi / Demo

Kaidah dependensi yang diterapkan:

$$\text{Presentation} \longrightarrow \text{Domain} \longleftarrow \text{Data}$$

1. **Presentation ke Domain:** `LoginPage` mengamati `authStateProvider`. `AuthNotifier` memanggil use case `Login` / `Logout`. Use case memanggil interface `AuthRepository`. Presentation hanya mengenal kontrak domain.
2. **Data ke Domain:** `AuthRepositoryImpl` mengimplementasikan interface `AuthRepository` dari domain. `AuthSessionModel` memetakan data JSON menjadi entity `AuthSession`. Data layer bergantung ke Domain (*inversion of control*).
3. **Domain Tidak Bergantung ke Mana Pun:** Domain adalah pusat logika (*core*). Domain tidak mengimpor Presentation maupun Data.
4. **Wiring DI Terpusat:** Di `auth_provider.dart`, Riverpod menyatukan seluruh dependensi: `authRepositoryProvider` mengembalikan `AuthRepositoryImpl` sebagai tipe `AuthRepository`.

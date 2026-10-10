# Hasil verifikasi output AI

| # | Pertanyaan verifikasi | Temuan |
|---|---|---|
| 1 | Apakah AI menaruh daftar catatan di SharedPreferences? | Tidak. Preferensi di SharedPreferences, catatan di database (SQLite lewat Drift atau sqflite). Sesuai keputusan saya karena SharedPreferences tidak punya query dan rapuh untuk koleksi |
| 2 | Apakah skema mendukung antrean sync (`dirty` / `updated_at`)? | Ya, skema AI punya penanda sync (`is_dirty`) dan `updated_at`, tetapi tidak persis sama dengan `db.dart`: AI memakai epoch millis dan kolom tambahan (`created_at`, `is_pinned`, `is_deleted`), sedangkan saya memakai `dirty` dan `updated_at` ISO-8601. AI juga menyarankan indeks (`idx_notes_list`, `idx_notes_dirty`) yang awalnya belum saya pakai; sekarang saya tambahkan `idx_notes_updated` dan `idx_notes_dirty` lewat versi database 2 dan `onUpgrade` |
| 3 | Apakah klaim "real-time" didukung stream? | Sesuai dokumentasi: Drift punya `watch()`, Hive punya `box.watch()`, sqflite tidak punya stream bawaan |
| 4 | Apakah estimasi boilerplate masuk akal? | sqflite saya buktikan sendiri (cukup `sqflite` + `path`, SQL string, `toMap`/`fromMap`). Drift hanya diperiksa lewat dokumentasi: butuh `drift`, `drift_flutter`, `drift_dev`, `build_runner`, dan file `.g.dart` |
| 5 | Keputusan final | AI merekomendasikan SharedPreferences untuk preferensi dan **Drift** untuk catatan, dengan sqflite sebagai alternatif. Saya mengikuti AI untuk preferensi, tetapi memilih **sqflite** untuk catatan: hanya ada satu tabel dengan antrean sync, sehingga code generation dan migrasi Drift tidak sebanding. Konsekuensinya, UI di-refresh manual lewat `ref.invalidate` |

## Temuan tambahan dari review kode

- `markAllSynced()` tidak dibahas AI dan berisiko menandai catatan baru sebagai tersinkron padahal belum terkirim. Diperbaiki dengan `dirtyIds()` + `markSynced(ids)`.
- Skema AI sudah memakai soft delete (`is_deleted`), sedangkan `deleteNote()` di aplikasi saya memakai hard delete sehingga penghapusan belum bisa disinkronkan. Dicatat sebagai keterbatasan.
- AI menyarankan key preferensi `theme_mode` (`system` / `light` / `dark`). Aplikasi saya memakai `dark_mode` (bool) dan `last_opened_at`, karena hanya butuh terang atau gelap.
- Saran pagination (`LIMIT/OFFSET`) dan FTS5 belum diterapkan di aplikasi ini.
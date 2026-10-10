# Output AI (Claude)

Jawaban Claude atas prompt di `01-prompt.md`, disalin tanpa diedit.

---

# Penyimpanan Lokal untuk Flutter Offline Notes

Aplikasi ini punya dua kebutuhan yang sifatnya berbeda:
- **Preferensi tema:** satu nilai kecil (misalnya `themeMode`), dibaca saat startup, hampir tanpa query.
- **Catatan:** data berjumlah ribuan dengan CRUD, urutan, pencarian, dan kemungkinan field sinkronisasi.

## Perbandingan per kriteria

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| **Kompleksitas query** | Tidak ada, hanya key-value | Terbatas: ambil per key atau iterasi lalu filter di Dart | Penuh (SQL: WHERE, ORDER BY, LIMIT, LIKE, FTS) | Penuh (SQL, ditulis lewat DSL Dart atau SQL langsung) |
| **Kebutuhan relasi** | Tidak bisa | Tidak ada relasi native, harus manual lewat ID | JOIN dan foreign key native | JOIN dan foreign key native, bertipe aman |
| **Reaktivitas (stream)** | Tidak ada | Ada (`box.watch()`, `listenable()`) | Tidak ada, harus buat sendiri | Ada, `watch()` pada query dan otomatis refresh saat tabel berubah |
| **Type-safety** | Rendah (`getString`, `getBool`, key berupa string) | Sedang (TypeAdapter, perlu generate) | Rendah (`Map<String, Object?>`, konversi manual) | Tinggi (class hasil generate, error terdeteksi saat compile) |
| **Boilerplate** | Sangat kecil | Sedang (adapter + generator) | Sedang: SQL manual, `fromMap`/`toMap`, migrasi manual | Terbesar di awal (code generation, `build_runner`), tapi paling sedikit kerja manual setelahnya |
| **Kemudahan testing** | Mudah (`setMockInitialValues`) | Cukup mudah (box di folder sementara) | Butuh `sqflite_common_ffi` atau database in-memory | Paling mudah (`NativeDatabase.memory()`, DAO dan stream bisa diuji) |

## Trade-off tiap pilihan

- **SharedPreferences:** paling sederhana dan cocok untuk setting. Kelemahannya, semua data dimuat dan ditulis sebagai satu kesatuan (di Android lewat XML/DataStore), sehingga tidak layak untuk ribuan catatan: tidak ada query, tidak ada indeks, dan performa menurun seiring ukuran data.
- **Hive:** cepat dan API-nya ringkas. Kelemahannya, box biasanya dimuat ke memori, query harus dilakukan manual di Dart, dan tidak ada relasi. Paket Hive aslinya juga sudah lama tidak aktif dikembangkan (ada fork komunitas `hive_ce`), jadi risiko pemeliharaan jangka panjang perlu dipertimbangkan.
- **sqflite:** SQL penuh dengan ketergantungan minimal, dan sangat baik untuk belajar SQL serta migrasi. Kelemahannya, tidak ada stream bawaan, tidak ada pengecekan tipe, dan tiap perubahan skema harus ditulis tangan di `onUpgrade`.
- **Drift:** lapisan type-safe di atas SQLite dengan stream reaktif, migrasi yang dibantu tooling, dan testing mudah. Kelemahannya, kurva belajar lebih curam, ada code generation (waktu build bertambah), dan ukuran dependensi lebih besar.

## Rekomendasi final

| Kebutuhan | Pilihan | Alasan utama |
|---|---|---|
| **Preferensi tema** | **SharedPreferences** | Datanya hanya 1–2 nilai kecil. Query, relasi, dan stream tidak diperlukan, dan boilerplate-nya paling kecil. |
| **Catatan (CRUD, 1000+ item)** | **Drift** | Daftar catatan perlu otomatis ter-update di UI (`watch()`), butuh `ORDER BY`, `LIMIT`/`OFFSET`, pencarian, dan indeks. Selain itu, type-safety dan testing in-memory menekan bug saat aplikasi berkembang. |
| *Alternatif catatan* | sqflite | Pilih ini jika tugas mensyaratkan SQL manual atau Anda ingin dependensi seminimal mungkin. Stream bisa dibuat sendiri lewat `StreamController` atau Riverpod, dengan lebih banyak kode manual. |

Hive tidak saya rekomendasikan untuk catatan karena filter dan pencarian harus dilakukan di memori dan tidak ada indeks.

## Skema untuk 1000+ catatan

**Tabel `notes` (SQL, berlaku untuk sqflite maupun Drift):**

```sql
CREATE TABLE notes (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  body        TEXT    NOT NULL DEFAULT '',
  created_at  INTEGER NOT NULL,            -- epoch millis
  updated_at  INTEGER NOT NULL,            -- epoch millis
  is_pinned   INTEGER NOT NULL DEFAULT 0,  -- 0/1
  is_dirty    INTEGER NOT NULL DEFAULT 0,  -- 1 = perlu disinkronkan
  is_deleted  INTEGER NOT NULL DEFAULT 0   -- soft delete agar bisa sinkron
);

-- Indeks untuk daftar utama: tampilkan yang belum dihapus, terbaru dulu
CREATE INDEX idx_notes_list ON notes (is_deleted, is_pinned DESC, updated_at DESC);

-- Indeks untuk antrean sinkronisasi
CREATE INDEX idx_notes_dirty ON notes (is_dirty) WHERE is_dirty = 1;
```

**Padanan di Drift:**

```dart
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**Query daftar dengan pagination (agar 1000+ catatan tetap ringan):**

```sql
SELECT id, title, substr(body, 1, 120) AS preview, updated_at, is_pinned
FROM notes
WHERE is_deleted = 0
ORDER BY is_pinned DESC, updated_at DESC
LIMIT 20 OFFSET :page * 20;
```

**Catatan penting untuk skala 1000+:**
- Ambil hanya kolom yang dibutuhkan di daftar (judul dan potongan isi), jangan memuat seluruh `body` untuk setiap baris.
- Gunakan pagination (`LIMIT/OFFSET`), atau *keyset pagination* (`WHERE updated_at < :last`) yang lebih stabil untuk data besar.
- Jika butuh pencarian teks penuh, tambahkan tabel virtual FTS5 untuk `title` dan `body`, bukan `LIKE '%kata%'` yang memindai seluruh tabel.
- Dengan 1000 catatan SQLite tidak bermasalah; indeks di atas lebih untuk menjaga kecepatan saat jumlahnya terus bertambah.

**Preferensi tema (SharedPreferences):**

| Key | Tipe | Nilai |
|---|---|---|
| `theme_mode` | String | `"system"` / `"light"` / `"dark"` |

Jika Anda memakai Riverpod, bungkus keduanya dalam provider: `themeModeProvider` untuk SharedPreferences dan `notesStreamProvider` yang mengambil stream dari Drift, agar UI otomatis ikut berubah.
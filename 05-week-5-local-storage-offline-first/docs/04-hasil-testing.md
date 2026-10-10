# Hasil testing

Tes: `test/note_repository_test.dart` (SQLite in-memory via `sqflite_common_ffi`).

| # | Tes | Yang dibuktikan |
|---|---|---|
| 1 | `addNote` menyimpan catatan dengan `dirty = true` | Catatan baru masuk antrean sync |
| 2 | `fetchNotes` mengurutkan dari `updated_at` terbaru | `ORDER BY updated_at DESC` bekerja |
| 3 | `deleteNote` menghapus catatan | Baris dan hitungan dirty ikut berkurang |
| 4 | `markSynced` hanya menandai id yang diberikan | Catatan lain tetap dirty |
| 5 | Catatan baru setelah `dirtyIds()` tetap dirty | Perbaikan risiko balapan pada sync |
| 6 | `syncNotes` mengembalikan jumlah dan mengosongkan antrean | Alur sync lengkap |
| 7 | `syncNotes` mengembalikan 0 bila tidak ada catatan dirty | Kasus antrean kosong |

```
flutter analyze
Analyzing week5_offline_notes...
No issues found! (ran in 10.8s)

flutter test
00:04 +7: All tests passed!
```

Cakupan tes terbatas pada `NoteRepository` dan `syncNotes()`; halaman UI, `PostRepository`, dan `PrefsRepository` diuji manual di emulator.
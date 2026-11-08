# AI Review Decisions (`docs/ai-review-decisions.md`)

Dokumen ini mendokumentasikan pelaksanaan **AI Challenge**: melakukan review kritis terhadap kode hasil generate AI, menentukan mana yang diterima, diterima dengan refactor, atau ditolak, serta menyertakan bukti empiris pengujian otomatis.

---

## 1. AI Review Prompt

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

---

## 2. Output Review AI (3 Temuan Asli)

1. **Temuan 1: Query search bocor antar-kunjungan halaman, Level: BLOCKER (kebenaran)**  
   `notesQueryProvider` tidak auto-dispose, sedangkan `TextField` tidak punya controller.
   - Pengguna mengetik `zzz`, lalu pindah halaman dan kembali.
   - Field tampil kosong, tetapi list masih terfilter `zzz` dan menampilkan "Tidak ada catatan yang cocok".
   - UI dan state tidak sinkron, sehingga catatan terlihat hilang.
2. **Temuan 2: Aturan filter berada di layer presentation, Level: SARAN (arsitektur)**  
   `n.title.toLowerCase().contains(q)` adalah aturan bisnis, tetapi ia berada di provider presentation. Untuk arsitektur `presentation -> domain <- data`, fungsi murni `filterNotesByTitle(List<Note>, String)` lebih tepat di `domain/`.
3. **Temuan 3: Cakupan test lemah, Level: SARAN (test)**  
   - Tidak ada test untuk empty state "Belum ada catatan" (DB kosong tanpa query), padahal itu cabang kedua `NotesEmptyState`.
   - Tidak ada test untuk query berisi spasi saja, yang seharusnya sama dengan query kosong.
   - Test 1 dan 2 tidak memanggil `c.dispose()` (`addTearDown(container.dispose)`).
   - Temuan 1 tidak ada test regresinya.

---

## 3. Tabel Usulan vs Keputusan

| # | Temuan AI | Level | Keputusan | Alasan Teknis | Bukti |
|:---:|---|---|:---:|---|---|
| **1** | Query bocor antar-kunjungan halaman | **Blocker** | **Terima** | Terbukti bug sinkronisasi UI saat halaman di-reopen; `TextField` tidak memiliki controller. Dibuktikan lewat test merah lalu diperbaiki dengan `TextEditingController`. | `docs/evidence/test-before.txt` & `test-after.txt` |
| **2** | Pindah aturan filter ke layer domain | **Saran** | **Terima + Refactor** | Diterapkan pada Refactoring Challenge dengan mengekstrak fungsi murni `filterNotesByTitle` ke `domain/filter_notes_by_title.dart`. Fungsi ini 100% murni Dart, dapat diuji unit test tanpa Riverpod/Flutter, dan bebas import lintas layer. | `lib/features/notes/domain/filter_notes_by_title.dart` & `test/search_filter_test.dart` |
| **3** | Cakupan test lemah (tambah 3 skenario & tearDown) | **Saran** | **Terima** | Meningkatkan keandalan test suite: menambahkan `addTearDown`, uji DB kosong ("Belum ada catatan"), uji query spasi, dan test regresi temuan 1. | `docs/evidence/test-after.txt` (9 passed di `search_filter_test.dart`) |
| **4** | Pindahkan pencarian ke SQL `LIKE` lewat repository | **Saran** | **Tolak** | Melanggar batas tugas "jangan ubah arsitektur, maks 80 baris". Mengubah kontrak repository dan layer data SQLite/Dio tidak efisien untuk dataset kecil di memori yang sudah di-cache oleh `notesProvider`. | Arsitektur SQLite & Dio tetap utuh, performa instan tanpa disk I/O berulang |

---

## 4. Keputusan Per File

| File | Keputusan | Tindakan Teknis |
|---|:---:|---|
| `filter_notes_by_title.dart` | **Baru (Refactor)** | Dibuat di layer domain murni: fungsi murni `filterNotesByTitle(List<Note>, String)` tanpa import Flutter/Riverpod. |
| `notes_search_provider.dart` | **Terima + Refactor** | Mendelegasikan filter logika ke domain use case `filterNotesByTitle`. |
| `notes_search_field.dart` | **Terima + Refactor** | Menambahkan `late final TextEditingController _ctrl = TextEditingController(text: ref.read(notesQueryProvider));` dan `_ctrl.dispose()`. |
| `notes_empty_state.dart` | **Terima** | Mempertahankan widget adaptif `isSearching` (ikon `search_off` vs `note_add_outlined`). |
| `notes_page.dart` | **Terima** | Tetap mengonsumsi `filteredNotesProvider`. |
| `search_filter_test.dart` | **Baru (Testing)** | Pengujian terisolasi fungsi domain murni, provider integration, dan widget test empty state + sinkronisasi controller. |
| `notes_search_test.dart` | **Terima + Refactor** | Menambahkan `addTearDown(container.dispose)`, test regresi temuan 1, test DB kosong, dan test query spasi. |

---

## 5. Bukti Empiris di Folder `docs/evidence/`

1. **`docs/evidence/test-before.txt`**  
   Mendokumentasikan kegagalan (*assertion failure*) saat field controller bernilai `null` dan tidak sinkron dengan `notesQueryProvider`:
   ```text
   Expected: 'zzz'
     Actual: <null>
   Test failed: field dan query tetap sinkron setelah halaman dibuka ulang
   ```
2. **`docs/evidence/test-after.txt`**  
   Mendokumentasikan seluruh 9 test case di `test/search_filter_test.dart` dan 6 test case di `test/features/notes/notes_search_test.dart` lulus 100%:
   ```text
   flutter test test/search_filter_test.dart
   00:01 +9: All tests passed!

   flutter test test/features/notes/notes_search_test.dart
   00:01 +6: All tests passed!
   ```
3. **`docs/evidence/analyze.txt`**  
   Mendokumentasikan analisis statis bebas error dan warning:
   ```text
   Analyzing notes_app...                                          
   No issues found! (ran in 4.5s)
   ```

---

## 6. Tabel Error Umum dan Solusinya

| Gejala | Penyebab Umum | Solusi |
|---|---|---|
| **Method tidak ada** | Halusinasi API | Cek pub.dev + autocomplete IDE |
| **Import lintas layer** | Konteks kurang | Tegaskan batas layer + refactor ke domain murni |
| **Semua test merah** | Prompt terlalu besar | Minta 1 fitur kecil + 1 test secara bertahap |
| **Prompt diulang terus** | Tanpa reproduksi | Tulis langkah reproduksi + tulis test merah |
| **Tak bisa menjelaskan** | Terima mentah | Baca ulang kode + sederhanakan arsitekturnya |

---

## 7. Checklist Verifikasi Mandiri
- [x] Prompt 5 slot + konteks di `docs/ai-log.md`
- [x] `flutter analyze` bersih (0 issues found)
- [x] `flutter test` hijau (semua test passed)
- [x] 1 temuan AI dibuktikan benar (`TextEditingController` null) + 1 ditolak beralasan (SQL `LIKE`)
- [x] Mampu menjelaskan keputusan tanpa membuka AI

---

## 8. Penjelasan Mandiri (Tanpa AI)

- **Mengapa Temuan 1 adalah Bug Nyata?**  
  Karena pada Flutter, widget `TextField` yang tidak diikat dengan `TextEditingController` akan merender teks kosong saat widget dibuat ulang (*rebuilt/re-entered*), sedangkan `notesQueryProvider` masih menyimpan query sebelumnya. Akibatnya, input terlihat kosong tetapi daftar catatan tetap terfilter, membuat pengguna mengira catatan mereka hilang secara misterius.
- **Mengapa Usulan SQL `LIKE` Ditolak?**  
  Karena aplikasi saat ini bekerja dengan dataset catatan di memori yang sudah di-cache oleh `notesProvider` sebagai *Single Source of Truth*. Memindahkan filter ke SQL `LIKE` membutuhkan panggilan I/O asynchronous berulang ke SQLite pada setiap ketikan (walaupun sudah ada debounce), merusak integritas *derived provider*, dan melanggar batasan ketat codelab untuk tidak mengubah arsitektur data.
- **Mengapa Logika Filter Dipindahkan ke Domain Murni?**  
  Dengan memindahkan fungsi `filterNotesByTitle` ke `domain/`, aturan pencarian menjadi *pure function* tanpa efek samping, dapat diuji menggunakan unit test standar tanpa bergantung pada Riverpod container maupun widget pump, serta mematuhi prinsip Clean Architecture (*separation of concerns*).

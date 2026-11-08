# Minggu 9: AI-Assisted Development

**Nama:** Angel Chelsea  
**NIM:** 244107020202  
**Repository:** `244107020202-mobile-course`  

## Daftar Isi
- [Praktikum 1: Prompt dan Context Engineering](#praktikum-1-prompt-dan-context-engineering)
- [Praktikum 2: Generate dan Verifikasi Search](#praktikum-2-generate-dan-verifikasi-search)
- [Praktikum 3: Refactoring, Testing, dan Error Umum](#praktikum-3-refactoring-testing-dan-error-umum)
- [AI Challenge: Review Kritis dan Keputusan](#ai-challenge-review-kritis-dan-keputusan)

---

## Praktikum 1: Prompt dan Context Engineering

### 1. Formula 5 Slot

Prompt yang digunakan untuk meminta AI membuat fitur search catatan:

```
Peran: senior Flutter dev
Konteks: feature-first, Riverpod, SQLite+Dio
Tugas: tambah search judul notes + empty state
Batas: jangan ubah arsitektur, maks 80 baris
Output: kode + 3 test case + cara uji
```

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <tr>
    <th align="center">Interaksi nyata prompt 5 slot di Claude AI</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/ss_01_claude_prompt_5slot.jpg" width="700" alt="Bukti prompt 5 slot Claude AI"></td>
  </tr>
</table>

### 2. Context Hygiene (Sanitasi Secret)

Sebelum kode dikirimkan ke AI, informasi sensitif disanitasi:
- Token autentikasi diubah menjadi `<AUTH_TOKEN_PLACEHOLDER>`
- Endpoint privat diubah menjadi `https://api.example.com/<ENDPOINT_PLACEHOLDER>`

---

## Praktikum 2: Generate dan Verifikasi Search

### 1. Implementasi Fitur

AI mengusulkan filter in-memory dengan *derived provider* tanpa mengubah skema SQLite:
- `notesQueryProvider`: menyimpan query pencarian.
- `filteredNotesProvider`: memfilter catatan secara in-memory.
- `NotesSearchField`: TextField dengan debounce 300ms.
- `NotesEmptyState`: widget adaptif saat catatan kosong atau hasil pencarian tidak ada.

### 2. Hasil Pengujian Aplikasi

<table border="1" cellpadding="8" cellspacing="0" align="center" width="750">
  <tr>
    <th align="center" width="33%">Kondisi default</th>
    <th align="center" width="33%">Pencarian cocok</th>
    <th align="center" width="33%">Empty state</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/ss_ui_01_default.png" width="230" alt="Kondisi default"></td>
    <td align="center"><img src="docs/screenshots/ss_ui_02_search_belanja.png" width="230" alt="Pencarian cocok"></td>
    <td align="center"><img src="docs/screenshots/ss_ui_03_empty_state_makanan.png" width="230" alt="Empty state"></td>
  </tr>
  <tr>
    <td align="center">Menampilkan seluruh catatan awal</td>
    <td align="center">Pencarian "belanja" (case-insensitive)</td>
    <td align="center">Pencarian "makanan" tidak ditemukan</td>
  </tr>
</table>

---

## Praktikum 3: Refactoring, Testing, dan Error Umum

### 1. Refactoring ke Domain Murni

Logika filter dipisahkan dari layer presentation ke fungsi domain murni (`filterNotesByTitle`):
- `lib/features/notes/domain/filter_notes_by_title.dart`: fungsi murni Dart, tanpa import Flutter/Riverpod.
- `lib/features/notes/presentation/providers/notes_search_provider.dart`: hanya mendelegasikan state ke use case domain.

### 2. Pemeriksaan Kode dan Hasil Test

Dijalankan dari folder `notes_app`:

| Perintah | Fungsi | Hasil |
|----------|--------|-------|
| `flutter analyze` | Analisis statis kode | No issues found! |
| `dart format --set-exit-if-changed .` | Periksa format kode | Formatted 0 files (0 changed) |
| `flutter test test/search_filter_test.dart` | Jalankan unit & widget test | +9: All tests passed! |

<table border="1" cellpadding="8" cellspacing="0" align="center" width="750">
  <tr>
    <th align="center">Hasil flutter analyze</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/ss_06_flutter_analyze.png" width="650" alt="Hasil flutter analyze"></td>
  </tr>
</table>

<table border="1" cellpadding="8" cellspacing="0" align="center" width="750">
  <tr>
    <th align="center">Hasil flutter test</th>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/ss_08_flutter_test.png" width="650" alt="Hasil flutter test"></td>
  </tr>
</table>

### 3. Error Umum dan Solusinya

| Gejala | Penyebab Umum | Solusi |
|--------|---------------|--------|
| Method tidak ada | Halusinasi API | Cek pub.dev + autocomplete |
| Import lintas layer | Konteks kurang | Tegaskan batas + refactor |
| Semua test merah | Prompt terlalu besar | Minta 1 fitur kecil + 1 test |
| Prompt diulang terus | Tanpa reproduksi | Tulis langkah + test merah |
| Tak bisa menjelaskan | Terima mentah | Baca ulang + sederhanakan |

---

## AI Challenge: Review Kritis dan Keputusan

### 1. Temuan Review AI dan Keputusan

AI diminta mereview kodenya sendiri dengan prompt review senior dev. Hasil evaluasi:

| # | Temuan AI | Level | Keputusan | Alasan Teknis |
|---|-----------|-------|-----------|---------------|
| 1 | Query search bocor antar-kunjungan halaman | **Blocker** | **Diterima** | Terbukti bug saat halaman di-reopen (`controller` bernilai null). Dibuktikan lewat test merah lalu diperbaiki dengan `TextEditingController`. |
| 2 | Aturan filter berada di layer presentation | Saran | **Diterima (Refactor)** | Dipindahkan ke `domain/filter_notes_by_title.dart` agar murni Dart dan bisa dites tanpa framework. |
| 3 | Cakupan test lemah | Saran | **Diterima** | Menambahkan `addTearDown`, uji DB kosong, uji spasi, dan widget test empty state. |
| 4 | Pindahkan search ke SQL `LIKE` | Saran | **Ditolak** | Melanggar batas 80 baris dan mengubah kontrak repository. Untuk data in-memory, filter CPU jauh lebih cepat tanpa disk I/O. |

### 2. Bukti Test Merah dan Perbaikan

Sebelum perbaikan, test gagal karena `field.controller` bernilai null:

```
Expected: 'zzz'
  Actual: <null>
Test failed: field dan query tetap sinkron setelah halaman dibuka ulang
```

Perbaikan pada `NotesSearchField`:

```dart
late final TextEditingController _ctrl =
    TextEditingController(text: ref.read(notesQueryProvider));

@override
void dispose() {
  _debounce?.cancel();
  _ctrl.dispose();
  super.dispose();
}
```

Setelah perbaikan, seluruh test lolos (+9 di `search_filter_test.dart` dan +6 di `notes_search_test.dart`).

### 3. Checklist Verifikasi Mandiri

- [x] Prompt 5 slot + konteks di [docs/ai-log.md](docs/ai-log.md)
- [x] `flutter analyze` bersih, `flutter test` hijau
- [x] 1 temuan AI dibuktikan benar + 1 ditolak beralasan
- [x] Mampu menjelaskan tiap keputusan tanpa membuka AI

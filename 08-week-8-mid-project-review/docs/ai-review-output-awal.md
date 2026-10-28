# Output Awal AI Review — Senior Flutter Developer

Berikut adalah salinan lengkap output ulasan kode awal yang diberikan oleh AI Reviewer (Senior Flutter Developer) terhadap branch `feat/notes-validation`:

---

### Ringkasan Review Awal
* **Status PR:** REQUEST CHANGES (BLOCKED)
* **Temuan Utama:** Terdapat 3 Blocker (ketahanan logika asinkron, memory leak, dan batas layer/integritas data) dan 2 Saran (kelengkapan test dan UX input).

---

### 5 Temuan Teratas dari AI

#### 1. Bypass Validasi Duplikasi saat State Async Belum Siap (*Silent Bypass*)
* **Lokasi:** `lib/pages/notes_page.dart` (baris 163–167)
* **Level:** **BLOCKER**
* **Alasan Teknis:**
  Pengambilan daftar judul dilakukan dengan:
  ```dart
  final titles = notes.asData?.value.map((n) => n.title).toList() ?? [];
  ```
  Ketika `notesProvider` sedang berada dalam status `AsyncLoading` atau `AsyncError`, nilai `notes.asData` bernilai `null`. Fallback `?? []` menghasilkan list kosong. Akibatnya, fungsi `validateTitleDuplicate` membandingkan input terhadap list kosong, sehingga catatan duplikat tetap tersimpan tanpa peringatan.
* **Usulan Kode Perbaikan:**
  ```dart
  floatingActionButton: FloatingActionButton(
    onPressed: notes.hasValue
        ? () {
            final titles = notes.requireValue.map((n) => n.title).toList();
            _showAddDialog(context, ref, titles);
          }
        : null,
    child: const Icon(Icons.add),
  ),
  ```

#### 2. Kebocoran Memori (*Memory Leak*) Akibat `TextEditingController` Tidak Di-dispose
* **Lokasi:** `lib/pages/notes_page.dart` (baris 18–76)
* **Level:** **BLOCKER**
* **Alasan Teknis:**
  Di dalam `_showAddDialog`, `title` dan `body` diinstansiasi setiap kali dialog dibuka tanpa pernah memanggil `dispose()`. Hal ini menyebabkan listener text binding tertahan di memori setiap kali dialog dibuka-tutup.
* **Usulan Kode Perbaikan:**
  ```dart
  try {
    final ok = await showDialog<bool>(...);
    if (ok == true && context.mounted) {
      await ref.read(notesProvider.notifier).add(title.text.trim(), body.text.trim());
    }
  } finally {
    title.dispose();
    body.dispose();
  }
  ```

#### 3. Pelanggaran Batas Layer & Integritas Data (Validasi Duplikasi Berada di UI Thread)
* **Lokasi:** `lib/pages/notes_page.dart` & `lib/data/repositories/note_repository.dart`
* **Level:** **BLOCKER** (Arsitektural)
* **Alasan Teknis:**
  Pengecekan keunikan data dilakukan secara in-memory di UI thread ($O(N)$ linear scan). Selain itu, layer repository dan SQLite tidak memiliki constraint unik atau pengecekan validasi, sehingga pemanggilan `add` di luar dialog berisiko meloloskan catatan duplikat.
* **Usulan Kode Perbaikan:**
  Pindahkan pengecekan ke repository via SQLite query:
  ```dart
  Future<bool> isTitleDuplicate(String title) async {
    final db = await _openDb();
    final result = await db.rawQuery(
      'SELECT 1 FROM notes WHERE LOWER(TRIM(title)) = LOWER(?) LIMIT 1',
      [title.trim()],
    );
    return result.isNotEmpty;
  }
  ```

#### 4. UX Flaw pada Validasi Input & Kurangnya Error Handling pada Eksekusi Simpan
* **Lokasi:** `lib/pages/notes_page.dart` (baris 31–76)
* **Level:** **SARAN**
* **Alasan Teknis:**
  1. `TextField` judul tidak memiliki handler `onChanged`, sehingga pesan error tidak langsung hilang saat user mulai memperbaiki teks.
  2. Pemanggilan `add` tidak dibungkus `try-catch`, berisiko menimbulkan uncaught exception jika SQLite gagal menulis.
* **Usulan Kode Perbaikan:**
  Tambahkan `onChanged` pada `TextField` untuk mereset pesan error dan pasang blok `try-catch` saat `add`.

#### 5. Ketiadaan Widget Test untuk Validasi Form & Interaksi Dialog
* **Lokasi:** `test/validators_test.dart`
* **Level:** **SARAN**
* **Alasan Teknis:**
  Pengujian hanya berupa unit test fungsi murni regex/string. Tidak ada Widget Test yang memverifikasi interaksi dialog (pesan error muncul, dialog tidak menutup saat input invalid, dsb.).
* **Usulan Kode Perbaikan:**
  Tambahkan test berbasis `testWidgets` untuk mensimulasikan dialog tambah catatan.


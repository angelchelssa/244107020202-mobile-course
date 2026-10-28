# Git Hygiene & Review Checklist

Dokumentasi audit riwayat commit, prinsip *atomic commit*, dan panduan standarisasi pesan commit berbasis *Conventional Commits* untuk tugas Mid-Project Review.

---

## 1. Prinsip Atomic Commit & Standarisasi Pesan

Dalam pengembangan perangkat lunak modern (khususnya kolaborasi tim dan proses *code review*), menjaga kebersihan riwayat Git (*Git hygiene*) merupakan praktik fundamental:

1. **Atomic Commit (Satu Komit, Satu Tujuan):**
   * Setiap commit harus merepresentasikan satu unit perubahan logis yang utuh (*independen*), dapat dikompilasi, dan lolos pengujian (*bisectable*).
   * **Manfaat:** Mempermudah pelacakan regresi menggunakan `git bisect`, memungkinkan pembatalan fitur spesifik melalui `git revert` tanpa merusak fitur lain, serta mempercepat proses *peer review* pada Pull Request.

2. **Conventional Commits:**
   * Menggunakan format baku: `<type>(<scope>): <deskripsi imperatif singkat>`
   * **Tipe Standar:**
     * `feat`: Penambahan fitur fungsional baru bagi pengguna.
     * `fix`: Perbaikan *bug* atau celah logika.
     * `docs`: Pembaruan dokumentasi, laporan, atau penambahan tangkapan layar.
     * `refactor`: Restrukturisasi kode tanpa mengubah fungsionalitas eksternal.
     * `test`: Penambahan atau perbaikan unit test/widget test.
     * `chore`: Tugas pemeliharaan rutin, konfigurasi *tooling*, atau migrasi file.

---

## 2. Tabel Simulasi Perbaikan Pesan Commit Buruk

Berdasarkan hasil audit riwayat git awal (`git log --oneline`), berikut adalah tabel matriks rekonstruksi commit buruk menjadi commit yang atomik, terstruktur, dan profesional:

| No | Commit Sebelum Perbaikan | Usulan Commit (*Conventional Commits*) | Masalah Riwayat | Alasan Teknis & Prinsip *Git Hygiene* |
|:--:|---|---|---|---|
| **1** | `docs: praktikum 2 screenshots` | `docs(week7): tambah screenshot hasil praktikum 2 clean architecture` | Ketiadaan scope, pesan kembar identik (`4cbf1bd` & `a2f69dc`), serta deskripsi tidak spesifik. | **Spesifisitas Scope & Audit Trail:** Menambahkan scope `(week7)` memperjelas modul yang terdampak tanpa perlu membaca `git diff`. Mencegah ambiguitas riwayat saat beberapa minggu memiliki nama praktikum yang mirip. |
| **2** | `feat(week6): implement campus_notify authentication, security, and FCM with complete report` | Dipecah menjadi 3 commit atomik terpisah:<br>• `feat(auth): implementasi login dan penyimpanan token aman`<br>• `feat(fcm): integrasi notifikasi push Firebase Messaging`<br>• `docs(week6): tambah laporan praktikum dan dokumentasi audit` | *Monolithic commit* (commit raksasa): mencampur tiga domain yang berbeda (autentikasi, FCM, dan laporan markdown) dalam satu commit ID (`ce97c47`). | **Atomic Commit & Bisectability:** Pelanggaran prinsip *Single Responsibility*. Jika integrasi FCM mengalami *bug*, `git revert` tidak dapat dilakukan tanpa ikut membatalkan autentikasi dan laporan. Pemisahan unit atomik menjamin isolasi risiko. |
| **3** | `refactor: establish week 7 clean architecture project copy and restore week 6 baseline` | Dipecah menjadi 2 commit atomik terpisah:<br>• `refactor(week7): salin modul campus_notify sebagai baseline clean architecture`<br>• `chore(week6): pulihkan baseline konfigurasi modul week 6` | *Multi-intent commit*: menggabungkan dua tujuan yang saling bertolak belakang (setup modul baru vs pemulihan modul lama) tanpa scope (`0ab281a`). | **Separation of Concerns:** Satu commit dilarang memiliki tujuan ganda (*mixed intent*). Memisahkan pekerjaan arsitektural (`refactor`) dari pemeliharaan repositori (`chore`) menjaga kejelasan changelog dan mempermudah telaah PR. |
| **4** | `feat(week5): catatan offline dengan SQLite, cache-first posts, dan sinkronisasi tunda` | Dipecah menjadi 2 commit atomik terpisah:<br>• `feat(notes): implementasi penyimpanan lokal catatan offline dengan SQLite`<br>• `feat(posts): implementasi cache-first posts dan sinkronisasi tunda` | *Compound feature commit*: mencakup dua fitur bisnis yang berbeda (`notes` dan `posts`) dalam satu commit besar (`1512491`). | **Modularitas Arsitektur:** Modul catatan lokal SQLite dan modul feed posts daring memiliki siklus dependensi dan stabilitas yang berbeda. Pemisahan per scope modul meningkatkan keterbacaan riwayat proyek. |

---

## 3. Checklist Evaluasi Commit Sebelum Push / Pull Request

Gunakan daftar periksa berikut sebelum melakukan commit atau mengajukan Pull Request ke branch utama:

- [✓] **Satu Tujuan per Commit:** Apakah commit ini hanya menyelesaikan satu tugas/isu tanpa perubahan di luar konteks?
- [✓] **Format Standar:** Apakah pesan commit mengikuti format `<type>(<scope>): <deskripsi>`?
- [✓] **Bukan Commit Raksasa:** Apakah file dokumentasi (.md/gambar) telah dipisahkan dari kode fungsional (.dart)?
- [✓] **Gaya Bahasa Imperatif:** Apakah deskripsi menggunakan kalimat aktif/imperatif (contoh: *"tambah validasi..."*, bukan *"menambahkan/menambahkan lagi..."*)?
- [✓] **Stage Selektif:** Apakah perubahan dipilah menggunakan `git add -p` untuk menghindari file sampah atau *whitespace noise* yang tidak sengaja ter-stage?
- [✓] **Lolos Verifikasi Lokal:** Apakah kode sudah dipastikan lulus `flutter analyze` dan `flutter test` sebelum commit dibuat?

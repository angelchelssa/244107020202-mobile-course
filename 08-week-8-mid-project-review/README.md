# Minggu 8: Mid Project Review & Code Review

**Nama:** Angel Chelsea
**NIM:** 244107020202
**Repository:** `244107020202-mobile-course`

## Daftar Isi
- [Praktikum 1: Hygiene Branch dan Commit](#praktikum-1-hygiene-branch-dan-commit)
- [Praktikum 2: PR dan Peer Review](#praktikum-2-pr-dan-peer-review)
- [Praktikum 3: Static Analysis dan Mid Review](#praktikum-3-static-analysis-dan-mid-review)

---

## Praktikum 1: Hygiene Branch dan Commit

### 1. Audit riwayat

Perintah yang dijalankan di root repository:

```
git --no-pager log --oneline -15
git branch -a
git status
```

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <tr>
    <th align="center">Audit riwayat, branch, dan status</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/p1-audit-git.png" width="700" alt="Audit riwayat dan branch"></td>
  </tr>
</table>

**Temuan:**

| Commit | Masalah |
|--------|---------|
| `4cbf1bd`, `a2f69dc` `docs: praktikum 2 screenshots` | Pesan identik dan tanpa scope |
| `ce97c47`, `a06a629` `feat(week6): implement ... with complete report` | Pesan kembar; satu commit memuat auth, security, FCM, dan laporan |
| `1512491` `feat(week5): catatan offline dengan SQLite, ...` | Terlalu banyak hal dalam satu commit; bahasa campur |
| `0ab281a` `refactor: establish week 7 ... restore week 6 baseline` | Tanpa scope; dua tujuan dalam satu commit |

**Branch:** branch `develop` belum ada, dan terdapat branch cadangan lokal `backup-before-repair-week6-week7`. **Working tree** bersih (tidak ada file tak terlacak).

### 2. Branch kerja yang benar

`develop` dibuat dari `main` satu kali dan di-push, lalu `feat/notes-validation` dibuat dari `develop`.

```
git checkout main
git checkout -b develop
git push -u origin develop
git checkout -b feat/notes-validation
```

Perubahan kecil yang dikerjakan: **validasi judul kosong** pada dialog "Catatan baru".

- `lib/utils/validators.dart`: fungsi `validateTitle`
- `lib/pages/notes_page.dart`: dialog memvalidasi judul dan menampilkan `errorText`
- `test/validators_test.dart`: test judul kosong, spasi, `null`, dan judul valid

Commit dibuat dengan `git add -p` agar hanya memuat perubahan yang terkait:

```
git commit -m "feat(notes): validasi judul kosong + test"
```

#### Hasil validasi judul

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <tr>
    <th align="center" width="33%">Judul kosong ditolak</th>
    <th align="center" width="33%">Input judul valid</th>
    <th align="center" width="33%">Catatan tersimpan</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/p1-validasi-judul.jpeg" width="230" alt="Judul kosong ditolak"></td>
    <td align="center"><img src="screenshots/p1-input-judul-valid.jpeg" width="230" alt="Input judul valid"></td>
    <td align="center"><img src="screenshots/p1-catatan-tersimpan.jpeg" width="230" alt="Catatan tersimpan"></td>
  </tr>
  <tr>
    <td align="center">Dialog tetap terbuka dengan pesan "Judul tidak boleh kosong"</td>
    <td align="center">Judul dan isi terisi</td>
    <td align="center">Catatan masuk daftar (belum sinkron)</td>
  </tr>
</table>

#### Hasil test

`flutter test` dijalankan dari `week5_offline_notes`:

<table border="1" cellpadding="8" cellspacing="0" align="center">
  <tr>
    <th align="center">Test lolos (+9: All tests passed!)</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/p1-flutter-test.png" width="700" alt="Hasil flutter test"></td>
  </tr>
</table>

### 3. Perbaikan commit buruk (simulasi)

Tabel lengkap ada di [docs/review-checklist.md](docs/review-checklist.md).

| Sebelum | Sesudah |
|---------|---------|
| `docs: praktikum 2 screenshots` | `docs(week7): tambah screenshot hasil praktikum 2 clean architecture` |
| `feat(week6): implement campus_notify authentication, ...` | `feat(auth): implementasi login dan penyimpanan token aman` (dipecah) |
| `refactor: establish week 7 ... restore week 6 baseline` | `refactor(week7): salin campus_notify ...` dan `chore(week6): pulihkan baseline` |

### Catatan pengelolaan folder

Latihan awalnya dikerjakan di `05-week-5-local-storage-offline-first`, lalu dipindahkan ke folder ini agar jobsheet 5 tetap utuh. Karena commit sudah di-push, riwayat tidak ditulis ulang (tanpa `reset` atau `force push`); pemindahan dilakukan dengan `git revert` dan `git mv`. Hasilnya `git diff --stat main -- 05-week-5-local-storage-offline-first` kosong.

| Commit | Keterangan |
|--------|-----------|
| `07f40cb` | `feat(notes): validasi judul kosong + test` |
| `bf03a0f` | Revert di folder 05 |
| `d6613f8` | Salin latihan ke folder minggu 8 |
| `c3b7a12` | `docs(week8): tambah checklist review dan tabel perbaikan commit` |
| `0b80c3b` | Pindah ke `08-week-8-mid-project-review` |

---

## Praktikum 2: PR dan Peer Review

**Pull Request:** (tempel link PR di sini)

---

## Praktikum 3: Static Analysis dan Mid Review

_(isi menyusul)_
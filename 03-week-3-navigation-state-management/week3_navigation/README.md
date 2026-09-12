# Praktikum 1 — Multi-Page Navigation dengan GoRouter

Proyek: `week3_navigation`

Navigasi antar halaman (Home → Detail) menggunakan `go_router` dengan path parameter `:id`.

---

## 1. Konsep Navigasi dan GoRouter

### Navigation dasar di Flutter

Navigasi adalah mekanisme berpindah antar layar. Di Flutter, setiap layar adalah *route* yang ditumpuk pada `Navigator` (stack). Cara lama (**Navigator 1.0**) menggunakan `Navigator.push`/`Navigator.pop` secara imperatif — sederhana, tetapi sulit dikelola pada aplikasi besar: route tidak terstruktur, deep link rumit, dan guard (misalnya redirect login) tersebar di banyak tempat.

### GoRouter

`GoRouter` adalah router deklaratif yang direkomendasikan Flutter. Konsep utamanya:

| Konsep | Penjelasan |
|---|---|
| `GoRoute` | Definisi path dan widget tujuan, misal `/`, `/detail/:id`. |
| `context.go()` | Pindah route (mengganti stack, cocok untuk redirect login). |
| `context.push()` | Tumpuk route baru di atas stack (cocok untuk detail). |
| path parameter | Nilai dinamis pada path, diakses lewat `state.pathParameters`. |
| `extra` | Mengirim objek antar route (gunakan hati-hati, tidak tersimpan saat proses restart web). |
| `redirect` | Guard navigasi terpusat, misal cek status login. |

---

## 2. Setup

```bash
flutter create week3_navigation
cd week3_navigation
flutter pub add go_router
```

Struktur folder:

```
lib/
├── main.dart
└── pages/
    ├── home_page.dart
    └── detail_page.dart
```

---

## 3. Penjelasan Implementasi

### `lib/main.dart`

Berisi konfigurasi `GoRouter` (`_router`) yang mendefinisikan dua route: `/` untuk `HomePage`, dan route bersarang `detail/:id` untuk `DetailPage` (nilai `:id` diambil dari `state.pathParameters`). `MyApp` menggunakan `MaterialApp.router` (bukan `MaterialApp` biasa) dengan parameter `routerConfig: _router`, sehingga seluruh navigasi aplikasi dikendalikan oleh GoRouter sejak awal.

### `lib/pages/home_page.dart`

Menampilkan `ListView` berisi 10 item. Setiap item, saat di-tap, memanggil `context.go('/detail/id')` untuk berpindah ke halaman detail sesuai nomor item — mengganti seluruh stack navigasi ke path baru.

### `lib/pages/detail_page.dart`

Menerima parameter `id` (String, wajib diisi) lalu menampilkannya baik di `AppBar` maupun di body halaman, sebagai bukti bahwa nilai dari path parameter berhasil diteruskan dari Home ke Detail.

---

## 4. Hasil

<table>
<tr>
<td align="center" width="50%"><b>Home</b></td>
<td align="center" width="50%"><b>Detail</b></td>
</tr>
<tr>
<td align="center"><img src="foto1.jpeg" width="220"></td>
<td align="center"><img src="foto2.jpeg" width="220"></td>
</tr>
</table>

**Pengamatan:**
- Path berubah sesuai layar aktif (`/` → `/detail/1`) saat item ditekan maupun saat tombol back sistem digunakan.
- Path `/detail/1` dapat diakses langsung tanpa melewati Home terlebih dahulu.
- Ini adalah keunggulan router deklaratif (GoRouter) dibanding `Navigator` 1.0 yang imperatif — struktur route lebih jelas dan mendukung deep link secara native.
# Hasil Uji Tiga App State dan Topik Notifikasi

Dokumentasi detail pengujian push notification Firebase Cloud Messaging (FCM) pada tiga kondisi aplikasi (*foreground*, *background*, *terminated*) dan siaran berbasis topik (*topic messaging*).

---

## 1. Payload Pengujian

Payload JSON yang digunakan untuk simulasi pengiriman notifikasi dari Firebase Console:

```json
{
  "notification": {
    "title": "Jadwal kuliah berubah",
    "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
  },
  "data": {
    "route": "/pengumuman/3",
    "id": "3"
  }
}
```

*Konfigurasi di Firebase Console:*
- **Notification title**: `Jadwal kuliah berubah`
- **Notification text**: `Kelas Mobile pindah ke Ruang A2 jam 13.00`
- **Custom data (Additional options)**:
  - `route` = `/pengumuman/3`
  - `id` = `3`

---

## 2. Matriks Hasil Pengujian

| Kondisi Aplikasi (*State*) | Perilaku yang Diharapkan | Langkah Pengujian | Status & Hasil |
|:---|:---|:---|:---:|
| **Foreground** | Banner lokal dari `flutter_local_notifications` muncul; ketukan pada banner mengarahkan ke `/pengumuman/3`. | Aplikasi dalam keadaan terbuka dan aktif di halaman utama, kirim pesan uji dari Firebase Console. | **BERHASIL** |
| **Background** | Banner sistem Android muncul otomatis di status bar / home screen; ketukan membuka aplikasi langsung ke `/pengumuman/3`. | Buka aplikasi, tekan tombol *Home* perangkat, kirim pesan dari Firebase Console, lalu ketuk banner notifikasi. | **BERHASIL** |
| **Terminated** | Banner sistem Android muncul saat proses aplikasi mati; ketukan meluncurkan aplikasi dari awal langsung menuju rute `/pengumuman/3` via `getInitialMessage()`. | Tutup aplikasi dari *Recent Apps* (swipe-close), kirim pesan dari Firebase Console, lalu ketuk notifikasi saat aplikasi tidak berjalan. | **BERHASIL** |
| **Topik (`pengumuman-kampus`)** | Notifikasi sampai ke seluruh perangkat yang berlangganan topik `pengumuman-kampus`. | Buat kampanye FCM baru dengan target *Topic* `pengumuman-kampus`. | **BERHASIL** |

---

## 3. Catatan Teknis Perilaku Navigasi

- Pada kondisi **Foreground** dan **Background**, halaman `AnnouncementPage (#3)` memiliki tombol kembali (*Back button*) karena stack navigasi `HomePage` telah berada di bawah tumpukan (*stack*).
- Pada kondisi **Terminated**, aplikasi langsung melakukan inisialisasi cold-start dan mengeksekusi `router.go('/pengumuman/3')` atau membuka rute awal, sehingga halaman pengumuman dapat dibuka secara langsung tanpa tumpukan halaman berulang.

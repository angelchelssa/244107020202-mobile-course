# Review Checklist

## Perbaikan Pesan Commit

| Sebelum | Sesudah | Alasan |
|---------|---------|--------|
| `docs: praktikum 2 screenshots` | `docs(week7): tambah screenshot hasil praktikum 2 clean architecture` | Menyebut minggu dan isi screenshot; sebelumnya dua commit memakai pesan identik |
| `feat(week6): implement campus_notify authentication, security, and FCM with complete report` | `feat(auth): implementasi login dan penyimpanan token aman` (dipecah dengan `feat(fcm): ...` dan `docs(week6): ...`) | Satu commit hanya satu perubahan logis, tidak mencampur kode dan laporan |
| `refactor: establish week 7 clean architecture project copy and restore week 6 baseline` | `refactor(week7): salin campus_notify sebagai dasar clean architecture` dan `chore(week6): pulihkan baseline` | Dua tujuan berbeda dipisah, plus scope jelas |
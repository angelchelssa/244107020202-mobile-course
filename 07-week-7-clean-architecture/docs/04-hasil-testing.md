# Hasil testing

Tes: `test/auth_repository_test.dart` (unit test repository) dan `test/widget_test.dart` (smoke test halaman login).

| # | Tes | Yang dibuktikan |
|---|---|---|
| 1 | `login` berhasil dengan kredensial valid | Mengembalikan `AuthSession` dengan mock token |
| 2 | `login` gagal jika email tanpa `@` | Mengembalikan `AuthFailure` |
| 3 | `login` gagal jika sandi kurang dari 6 karakter | Mengembalikan `AuthFailure` |
| 4 | `refresh` mengembalikan token baru jika refresh token valid | Token berhasil diperbarui |
| 5 | `refresh` mengembalikan failure jika refresh token kosong | Mengembalikan `AuthFailure` |
| 6 | `logout` berhasil | Mengembalikan failure null |
| 7 | Smoke test: `LoginPage` tampil saat cold-start tanpa token | UI login tampil saat awal dibuka |

```
flutter analyze
Analyzing campus_notify...
No issues found! (ran in 10.7s)

flutter test
00:03 +7: All tests passed!
```

Pengujian unit test berfokus pada kontrak `AuthRepositoryImpl` dan penanganan error ke `AuthFailure`, sedangkan alur navigasi dan UI diuji secara manual di emulator Android.

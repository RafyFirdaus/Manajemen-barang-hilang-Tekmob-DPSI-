# Manajemen Barang Hilang

Aplikasi Flutter untuk manajemen barang hilang yang membantu pengguna menemukan dan mengembalikan barang yang hilang.

## Fitur

### Autentikasi
- **Layar Welcome**: Berfungsi sebagai layar loading dengan animasi circular progress indicator dan navigasi otomatis ke layar login setelah 3 detik.
- **Login**: Form login dengan validasi email dan password, serta penanganan error.
- **Register**: Form pendaftaran dengan validasi lengkap untuk semua field (nama, email, password, konfirmasi password, nomor telepon).

### Layanan
- **AuthService**: Implementasi dummy service untuk simulasi autentikasi dengan `Future.delayed()` untuk mensimulasikan panggilan API.
  - Login: Validasi email dan password dengan simulasi respons sukses/gagal.
  - Register: Validasi data pendaftaran dengan simulasi respons sukses/gagal.

## Struktur Folder

```
lib/
├── main.dart
└── src/
    ├── assets/
    │   └── images/       # Gambar SVG dan aset lainnya
    ├── screens/
    │   ├── auth/         # Layar login dan register
    │   └── welcome/      # Layar welcome/loading
    ├── services/         # Layanan API dummy
    └── widgets/          # Widget yang dapat digunakan kembali
```

## Catatan Pengembangan

Aplikasi ini menggunakan dummy API calls karena belum ada backend API yang tersedia. Semua panggilan API disimulasikan menggunakan `Future.delayed()` untuk memberikan pengalaman yang realistis.

Untuk login testing, gunakan:
- Email: test@example.com
- Password: password123

## Memulai

1. Clone repository ini
2. Jalankan `flutter pub get` untuk menginstall dependencies
3. Jalankan `flutter run` untuk memulai aplikasi

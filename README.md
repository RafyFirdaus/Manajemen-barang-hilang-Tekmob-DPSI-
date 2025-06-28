# Manajemen Barang Hilanglutter untuk manajemen barang hilang yang membantu pengguna menemukan dan mengembalikan barang yang hilang. Aplikasi ini sudah terintegrasi dengan **API Express** untuk backend yang lengkap.

## Fitur an animasi dan navigasi otomatis
- **Login**: Autentikasi pengguna dengan validasi email dan password
- **Register**: Pendaftaran pengguna baru dengan validasi lengkap
- **Secure Storage**: Penyimpanan token autentikasi yang aman
- **Role-based Access**: Sistem peran pengguna (User/Satpam)

### 📋 Manajemen Laporan
- **Tambah Laporan**: Form lengkap untuk membuat laporan kehilangan atau temuan
- **Upload Foto**: Fitur upload multiple foto untuk setiap laporan
- **Kategori Laporan**: 
  - Laporan Kehilangan
  - Laporan Temuan
- **Detail Laporan**: Informasi lengkap termasuk nama barang, lokasi, tanggal, deskripsi, dan gambar

### 👥 Dashboard Multi-Role
- **User Dashboard**: 
  - Melihat semua laporan
  - Filter berdasarkan jenis laporan
  - Pencarian laporan
  - Membuat laporan baru
  - **Riwayat Laporan**: Melihat semua laporan yang dibuat oleh user
- **Satpam Dashboard**:
  - Mengelola semua laporan


### 🎨 Komponen UI Modern
- **Dashboard Header**: Header dashboard dengan greeting dan navigasi tab
- **Dashboard Search Bar**: Search bar dengan ikon filter terintegrasi
- **Dashboard Tab Bar**: Tab bar dengan desain modern dan animasi smooth
- **Report Card**: Kartu laporan dengan status indicator dan layout responsif
- **Report List View**: List view yang dapat di-scroll dengan empty state
- **Report Detail Modal**: Modal detail laporan dengan informasi lengkap

### 🖼️ Fullscreen Image Viewer
- **Zoom & Pan**: Fitur zoom in/out dan pan untuk melihat detail gambar
- **Multi-Image Navigation**: Navigasi antar gambar dengan swipe gesture
- **Interactive Viewer**: Viewer interaktif dengan boundary margin
- **Fullscreen Experience**: Tampilan fullscreen dengan background hitam
- **Easy Integration**: Dapat dipanggil dari mana saja dengan static method

### 🌐 Integrasi API Express
- **Base URL**: `https://api-manajemen-barang-hilang.vercel.app/api`
- **Endpoints Terintegrasi**:
  - `POST /login` - Autentikasi pengguna
  - `POST /register` - Registrasi pengguna baru
  - `GET /reports` - Mengambil semua laporan
  - `POST /reports` - Membuat laporan baru
  - `GET /reports/user/:userId` - Mengambil laporan berdasarkan user ID
  - `PUT /reports/:id/status` - Update status laporan
  - `DELETE /reports/:id` - Hapus laporan
- **Fallback System**: Local storage sebagai backup jika API tidak tersedia
- **Token Authentication**: Bearer token untuk keamanan API

## Struktur Folder

```
lib/
├── main.dart
└── src/
    ├── assets/
    │   └── images/           # Gambar SVG dan aset lainnya
    ├── components/           # Komponen UI yang dapat digunakan kembali
    ├── models/
    │   └── report_model.dart # Model data laporan
    ├── screens/
    │   ├── auth/             # Layar login dan register
    │   ├── dashboard/        # Dashboard user dan satpam
    │   ├── welcome/          # Layar welcome/loading
    │   └── add_report_screen.dart # Layar tambah laporan
    ├── services/
    │   ├── auth_service.dart # Service autentikasi dengan API
    │   └── report_service.dart # Service manajemen laporan dengan API
    └── widgets/              # Widget yang dapat digunakan kembali
        ├── dashboard_header.dart      # Header dashboard dengan greeting
        ├── dashboard_search_bar.dart  # Search bar dengan filter
        ├── dashboard_tab_bar.dart     # Tab bar dengan desain modern
        ├── fullscreen_image_viewer.dart # Viewer gambar fullscreen
        ├── report_card.dart           # Kartu laporan dengan status
        ├── report_detail_modal.dart   # Modal detail laporan
        └── report_list_view.dart      # List view laporan
```

## Teknologi yang Digunakan

- **Flutter**: Framework utama untuk mobile development
- **HTTP Package**: Untuk komunikasi dengan API Express
- **Flutter Secure Storage**: Penyimpanan token yang aman
- **Shared Preferences**: Local storage untuk backup data
- **Image Picker**: Upload dan pilih gambar
- **Google Fonts**: Typography yang konsisten
- **Flutter SVG**: Dukungan gambar SVG
- **Intl**: Formatting tanggal dan waktu

## Instalasi dan Menjalankan Aplikasi

### Prasyarat
- Flutter SDK (versi terbaru)
- Dart SDK
- Android Studio / VS Code
- Emulator Android atau perangkat fisik

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/username/Manajemen-barang-hilang-Tekmob-DPSI-.git
   cd Manajemen-barang-hilang-Tekmob-DPSI-
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## Konfigurasi API

Aplikasi sudah dikonfigurasi untuk menggunakan API Express yang di-deploy di Vercel:
- **Production API**: `https://api-manajemen-barang-hilang.vercel.app/api`
- **Local Development**: Ubah `baseUrl` di `auth_service.dart` dan `report_service.dart`

## Fitur Keamanan

- **Token-based Authentication**: Menggunakan JWT token
- **Secure Storage**: Token disimpan dengan aman menggunakan Flutter Secure Storage
- **Input Validation**: Validasi lengkap pada semua form input
- **Error Handling**: Penanganan error yang komprehensif
- **Offline Support**: Fallback ke local storage jika API tidak tersedia

## 📊 Fitur Riwayat Laporan

### Deskripsi
Fitur ini memungkinkan user untuk melihat semua laporan yang pernah mereka buat, baik laporan barang hilang maupun laporan barang temuan.

### Fitur Utama
- **Tampilan Terorganisir**: Laporan dipisahkan dalam tab "Barang Hilang" dan "Barang Temuan"
- **Indikator Status**: Setiap laporan menampilkan status terkini (Proses, Terverifikasi, Selesai, dll.)
- **Informasi Lengkap**: Menampilkan nama barang, lokasi, tanggal kejadian, dan tanggal pembuatan
- **Refresh**: Fitur pull-to-refresh untuk memperbarui data
- **Integrasi API**: Mengambil data dari server dengan fallback ke penyimpanan lokal
- **Fallback Lokal**: Jika API tidak tersedia, data diambil dari SharedPreferences

### Cara Penggunaan
1. Login ke aplikasi sebagai user
2. Klik tab "Laporan" di bottom navigation
3. Pilih tab "Barang Hilang" atau "Barang Temuan"
4. Tap pada kartu laporan untuk melihat detail lengkap
5. Pull down untuk refresh data

### Implementasi Teknis
- **Screen**: `UserReportsScreen` di `/lib/src/screens/reports/`
- **Service**: Method `getReportsByUserId()` di `ReportService`
- **API Endpoint**: `GET /api/reports/user/:userId`
- **Navigasi**: Terintegrasi dengan bottom navigation bar di dashboard user

### Troubleshooting
**Masalah**: Laporan yang dibuat user tidak muncul di halaman riwayat laporan
**Solusi**: Pastikan `userId` yang digunakan saat menyimpan laporan sama dengan yang digunakan saat mengambil laporan. Dalam implementasi ini, menggunakan `userData['id']` untuk konsistensi.

## Fitur Notifikasi

Aplikasi ini dilengkapi dengan sistem notifikasi yang akan memberitahu user ketika status laporan mereka berubah.

### Kapan Notifikasi Muncul
- Ketika status laporan berubah dari "Proses" ke "Cocok" (laporan berhasil dicocokkan oleh satpam)
- Ketika status laporan berubah ke "Terverifikasi"
- Ketika status laporan berubah ke "Selesai"

### Fitur Notifikasi
- **Badge Notifikasi**: Menampilkan jumlah notifikasi yang belum dibaca di navbar
- **Daftar Notifikasi**: Menampilkan semua notifikasi dengan detail perubahan status
- **Tandai Dibaca**: User dapat menandai notifikasi sebagai sudah dibaca
- **Navigasi**: Tap notifikasi untuk melihat detail laporan terkait
- **Hapus Notifikasi**: User dapat menghapus notifikasi yang tidak diperlukan

### Cara Menggunakan
1. Buka aplikasi dan login sebagai user
2. Buat laporan baru melalui menu "Tambah"
3. Tunggu satpam memproses dan mengubah status laporan
4. Notifikasi akan muncul di navbar dengan badge merah
5. Tap menu "Notifikasi" untuk melihat detail notifikasi
6. Tap notifikasi untuk melihat detail laporan atau tandai sebagai dibaca

## Troubleshooting

### User Reports Not Appearing
Jika laporan yang dibuat user tidak muncul di halaman riwayat laporan:

1. **Periksa konsistensi userId**: Pastikan `userId` yang digunakan untuk menyimpan dan mengambil laporan konsisten
2. **Gunakan `userData['id']`**: Dalam `add_report_screen.dart`, pastikan menggunakan `userData['id']` sebagai `userId`, bukan `userData['email']`
3. **Restart aplikasi**: Setelah melakukan perubahan, restart aplikasi untuk memastikan perubahan diterapkan

Contoh implementasi yang benar:
```dart
final userData = await _authService.getUserData();
final userId = userData['id']; // Gunakan 'id', bukan 'email'
```

### Notifikasi Tidak Muncul
Jika notifikasi tidak muncul setelah status laporan berubah:

1. **Periksa userId**: Pastikan `userId` yang digunakan konsisten antara laporan dan notifikasi
2. **Restart aplikasi**: Tutup dan buka kembali aplikasi untuk refresh data
3. **Periksa status laporan**: Notifikasi hanya muncul untuk perubahan status tertentu (Proses → Cocok)
4. **Clear cache**: Hapus data aplikasi jika diperlukan

## Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## Lisensi

Project ini menggunakan lisensi MIT. Lihat file `LICENSE` untuk detail lebih lanjut.

## Tim Pengembang

- **Mobile Development**: Flutter Team
- **Backend API**: Express.js Team
- **UI/UX Design**: Design Team

---

**Catatan**: Aplikasi ini dikembangkan sebagai bagian dari project DPSI

# Manajemen Barang Hilang

Aplikasi Flutter untuk manajemen barang hilang yang membantu pengguna menemukan dan mengembalikan barang yang hilang. Aplikasi ini sudah terintegrasi dengan **API Express** untuk backend yang lengkap.

## Fitur Utama

### 🔐 Sistem Autentikasi
- **Layar Welcome**: Layar loading dengan animasi dan navigasi otomatis
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
- **Satpam Dashboard**:
  - Mengelola semua laporan
  - Approve/Reject laporan
  - Update status laporan
  - Monitoring laporan real-time

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

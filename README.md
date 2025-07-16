# Manajemen Barang Hilang

Aplikasi Flutter untuk manajemen barang hilang yang membantu pengguna menemukan dan mengembalikan barang yang hilang. Aplikasi ini sudah terintegrasi dengan **API Express** untuk backend yang lengkap dan menggunakan **AI Hugging Face** untuk pencocokan otomatis.

## 🚀 Fitur Utama

### 🔐 Autentikasi dan Keamanan
- **Login**: Autentikasi pengguna dengan validasi email dan password
- **Register**: Pendaftaran pengguna baru dengan validasi lengkap
- **Secure Storage**: Penyimpanan token autentikasi yang aman
- **Role-based Access**: Sistem peran pengguna (User/Tamu, Satpam, Admin)
- **Token-based Authentication**: Menggunakan JWT token
- **Input Validation**: Validasi lengkap pada semua form input
- **Error Handling**: Penanganan error yang komprehensif

### 📋 Manajemen Laporan
- **Tambah Laporan**: Form lengkap untuk membuat laporan kehilangan atau temuan
- **Upload Foto**: Fitur upload multiple foto untuk setiap laporan
- **Kategori Laporan**: 
  - Laporan Kehilangan
  - Laporan Temuan
- **Detail Laporan**: Informasi lengkap termasuk nama barang, lokasi, tanggal, deskripsi, dan gambar
- **Status Tracking**: Pelacakan status laporan (Proses, Terverifikasi, Cocok, Selesai)
- **Riwayat Laporan**: User dapat melihat semua laporan yang pernah dibuat

### 👥 Dashboard Multi-Role
- **User Dashboard**: 
  - Melihat semua laporan
  - Filter berdasarkan jenis laporan
  - Pencarian laporan
  - Membuat laporan baru
  - Melihat riwayat laporan pribadi
- **Satpam Dashboard**:
  - Mengelola semua laporan
  - Fitur pencocokan manual dan otomatis
  - Verifikasi laporan
  - Update status laporan

### 🤖 Sistem Pencocokan AI
- **Pencocokan Otomatis**: Menggunakan AI Hugging Face untuk mencocokkan laporan hilang dan temuan
- **Pencocokan Manual**: Satpam dapat mencocokkan laporan secara manual
- **Similarity Score**: Sistem scoring untuk tingkat kemiripan
- **Smart Matching**: Algoritma cerdas berdasarkan deskripsi barang
- **Threshold Configuration**: Pengaturan ambang batas kemiripan

### 📱 Sistem Klaim
- **Form Klaim**: Formulir untuk mengklaim barang yang ditemukan
- **Foto Bukti**: Upload foto sebagai bukti klaim
- **Verifikasi Identitas**: Sistem verifikasi untuk memastikan pemilik yang sah
- **Status Klaim**: Pelacakan status proses klaim
- **Konfirmasi Klaim**: Sistem konfirmasi sebelum menyelesaikan klaim

### 🔔 Sistem Notifikasi
- **Real-time Notifications**: Notifikasi real-time untuk perubahan status
- **Badge Counter**: Penghitung notifikasi yang belum dibaca
- **Status Change Alerts**: Pemberitahuan ketika status laporan berubah
- **Mark as Read**: Fitur tandai sebagai sudah dibaca
- **Delete Notifications**: Hapus notifikasi yang tidak diperlukan
- **User-specific**: Notifikasi khusus untuk setiap user


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

## 📁 Struktur Folder

### Frontend (Flutter)
```
lib/
├── main.dart                    # Entry point aplikasi
└── src/
    ├── assets/
    │   └── images/              # Gambar SVG dan ikon
    │       ├── Box_open_fill.svg
    │       ├── ButtonActive.svg
    │       ├── ButtonDefault.svg
    │       ├── welcome image.svg
    │       └── ...
    ├── models/                  # Data models
    │   ├── report_model.dart    # Model laporan
    │   ├── notification_model.dart # Model notifikasi
    │   ├── klaim_model.dart     # Model klaim
    │   ├── kategori_model.dart  # Model kategori
    │   └── lokasi_model.dart    # Model lokasi
    ├── screens/                 # Layar aplikasi
    │   ├── auth/                # Autentikasi
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── dashboard/           # Dashboard
    │   │   ├── user_dashboard_screen.dart
    │   │   └── satpam_dashboard_screen.dart
    │   ├── reports/             # Laporan
    │   │   └── user_reports_screen.dart
    │   ├── matching/            # Pencocokan
    │   │   ├── matching_screen.dart
    │   │   └── matching_detail_screen.dart
    │   ├── klaim/               # Klaim
    │   │   └── klaim_form_screen.dart
    │   ├── notifications/       # Notifikasi
    │   │   └── notifications_screen.dart
    │   ├── profile/             # Profil
    │   │   └── profile_screen.dart
    │   ├── welcome/             # Welcome
    │   │   └── welcome_screen.dart
    │   └── add_report_screen.dart # Tambah laporan
    ├── services/                # Business logic
    │   ├── auth_service.dart    # Service autentikasi
    │   ├── report_service.dart  # Service laporan
    │   ├── matching_service.dart # Service pencocokan AI
    │   ├── notification_service.dart # Service notifikasi
    │   ├── klaim_service.dart   # Service klaim
    │   ├── kategori_service.dart # Service kategori
    │   └── lokasi_service.dart  # Service lokasi
    └── widgets/                 # Reusable widgets
        ├── custom_button.dart   # Tombol kustom
        ├── dashboard_header.dart # Header dashboard
        ├── dashboard_search_bar.dart # Search bar
        ├── dashboard_tab_bar.dart # Tab bar
        ├── fullscreen_image_viewer.dart # Image viewer
        ├── report_detail_card.dart # Kartu detail laporan
        ├── report_detail_modal.dart # Modal detail
        └── report_list_view.dart # List view laporan
```

### Backend (Express.js)
```
API_Manajemen_Barang_Hilang/
├── app.js                       # Entry point server
├── package.json                 # Dependencies
├── .env.example                 # Template environment
├── config/
│   ├── firebase.js              # Konfigurasi Firebase Admin
│   └── firebaseConfig.js        # Konfigurasi Firebase Client
├── middleware/
│   ├── auth.js                  # Middleware autentikasi
│   └── upload.js                # Middleware upload file
├── routes/
│   ├── login.js                 # Route login
│   ├── register.js              # Route register
│   ├── users.js                 # Route user management
│   ├── laporan.js               # Route laporan
│   ├── cocok.js                 # Route pencocokan
│   ├── klaim.js                 # Route klaim
│   ├── kategori.js              # Route kategori
│   └── lokasi.js                # Route lokasi
└── api/
    └── cron/                    # Scheduled tasks
```

### AI Matching Service
```
apihf-pencocokan-mbh/            # Next.js API untuk AI matching
├── app/
│   ├── api/                     # API endpoints
│   ├── page.tsx                 # Landing page
│   └── layout.tsx               # Layout
├── package.json                 # Dependencies
└── next.config.ts               # Next.js config
```

## 🛠️ Teknologi yang Digunakan

### Frontend (Flutter)
- **Flutter**: Framework utama untuk mobile development
- **HTTP Package**: Untuk komunikasi dengan API Express
- **Flutter Secure Storage**: Penyimpanan token yang aman
- **Shared Preferences**: Local storage untuk backup data
- **Image Picker**: Upload dan pilih gambar dari kamera/galeri
- **Google Fonts**: Typography yang konsisten
- **Flutter SVG**: Dukungan gambar SVG
- **Intl**: Formatting tanggal dan waktu
- **Permission Handler**: Manajemen permission aplikasi
- **Flutter Launcher Icons**: Kustomisasi ikon aplikasi

### Backend (Express.js)
- **Express.js**: Framework backend Node.js
- **Firebase Admin SDK**: Autentikasi dan database
- **Firebase Storage**: Penyimpanan file dan gambar
- **Multer**: Upload file middleware
- **JWT**: Token-based authentication
- **CORS**: Cross-origin resource sharing

### AI & Machine Learning
- **Hugging Face Transformers**: Model AI untuk text similarity
- **Sentence Transformers**: Model untuk embedding text
- **all-MiniLM-L6-v2**: Pre-trained model untuk semantic similarity

### Database & Storage
- **Firebase Firestore**: NoSQL database untuk data aplikasi
- **Firebase Storage**: Cloud storage untuk gambar dan file
- **Local Storage**: SharedPreferences untuk cache offline

## 📦 Instalasi dan Setup

### Prasyarat
- **Flutter SDK** (versi 3.4.0 atau lebih baru)
- **Dart SDK** (sudah termasuk dalam Flutter)
- **Android Studio** / **VS Code** dengan ekstensi Flutter
- **Emulator Android** atau **perangkat fisik**
- **Node.js** (untuk menjalankan backend API)
- **Firebase Account** (untuk database dan storage)
- **Hugging Face Account** (untuk AI matching)

### 🚀 Langkah Instalasi

#### 1. Clone Repository
```bash
git clone https://github.com/username/Manajemen-barang-hilang-Tekmob-DPSI-.git
cd Manajemen-barang-hilang-Tekmob-DPSI-
```

#### 2. Setup Backend API
```bash
cd API_Manajemen_Barang_Hilang
npm install
```

#### 3. Konfigurasi File Environment (.env)

##### 3.1 Buat File .env untuk Backend

Buat file `.env` di direktori `API_Manajemen_Barang_Hilang/` berdasarkan `.env.example`:

```bash
cp .env.example .env
```

##### 3.2 Konfigurasi Backend .env

Edit file `.env` dan isi dengan konfigurasi yang sesuai:

```env
# Application Configuration
PORT=3000
NODE_ENV=development

# Firebase Admin SDK
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=your-firebase-client-email@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"

# Firebase Client SDK
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_APP_ID=your-firebase-app-id

# Hugging Face Configuration
HUGGING_FACE_TOKEN=your-hugging-face-token
HUGGING_FACE_MODEL=sentence-transformers/all-MiniLM-L6-v2

# Database Configuration (jika menggunakan database lain)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=manajemen_barang_hilang
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_here

# Upload Configuration
MAX_FILE_SIZE=5242880  # 5MB
UPLOAD_PATH=./uploads
```

##### 3.3 Konfigurasi AI Matching Service .env

Buat file `.env.local` di direktori `apihf-pencocokan-mbh/`:

```env
# Hugging Face Configuration
HUGGING_FACE_API_KEY=your_hugging_face_token_here
HUGGING_FACE_MODEL=sentence-transformers/all-MiniLM-L6-v2

# API Configuration
API_BASE_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3000

# Security
API_SECRET_KEY=your_api_secret_key
```

#### 4. Setup Token Hugging Face

##### 4.1 Mendapatkan Token Hugging Face

**a. Buat Akun Hugging Face**
1. Kunjungi [https://huggingface.co/](https://huggingface.co/)
2. Klik "Sign Up" dan buat akun baru
3. Verifikasi email Anda

**b. Generate Access Token**
1. Login ke akun Hugging Face
2. Kunjungi [Settings > Access Tokens](https://huggingface.co/settings/tokens)
3. Klik "New token"
4. Berikan nama token (contoh: "ManajemenBarangHilang")
5. Pilih role "Read" (cukup untuk menggunakan model)
6. Klik "Generate a token"
7. **PENTING**: Salin token dan simpan dengan aman

##### 4.2 Konfigurasi Token di Aplikasi

**a. Update AI Matching Service**

Edit file `.env.local` di `apihf-pencocokan-mbh/`:
```env
HUGGING_FACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**b. Update Flutter Service**

Edit file `lib/src/services/matching_service.dart`:
```dart
class MatchingService {
  static const String _hfToken = 'hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  // ... rest of the code
}
```

##### 4.3 Verifikasi Token

Untuk memverifikasi token berfungsi, jalankan test sederhana:

```bash
curl -H "Authorization: Bearer hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
     https://api-inference.huggingface.co/models/sentence-transformers/all-MiniLM-L6-v2
```

#### 5. Setup Firebase

##### 5.1 Buat Project Firebase

1. Kunjungi [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Create a project"
3. Masukkan nama project (contoh: "manajemen-barang-hilang")
4. Aktifkan Google Analytics (opsional)
5. Klik "Create project"

##### 5.2 Konfigurasi Authentication

1. Di Firebase Console, pilih "Authentication"
2. Klik "Get started"
3. Pilih tab "Sign-in method"
4. Aktifkan "Email/Password"
5. Klik "Save"

##### 5.3 Konfigurasi Firestore Database

1. Di Firebase Console, pilih "Firestore Database"
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih lokasi server terdekat
5. Klik "Done"

##### 5.4 Konfigurasi Firebase Storage

1. Di Firebase Console, pilih "Storage"
2. Klik "Get started"
3. Pilih lokasi server terdekat
4. Klik "Done"

##### 5.5 Generate Service Account Key

1. Di Firebase Console, klik ⚙️ (Settings) > "Project settings"
2. Pilih tab "Service accounts"
3. Klik "Generate new private key"
4. Download file JSON
5. Extract informasi berikut untuk file `.env`:
   - `project_id` → `FIREBASE_PROJECT_ID`
   - `client_email` → `FIREBASE_CLIENT_EMAIL`
   - `private_key` → `FIREBASE_PRIVATE_KEY`

##### 5.6 Konfigurasi Web App

1. Di Firebase Console, klik ⚙️ (Settings) > "Project settings"
2. Scroll ke bawah, klik "Add app" > Web (</>) icon
3. Masukkan nickname app
4. Klik "Register app"
5. Salin konfigurasi untuk file `.env`:
   - `apiKey` → `FIREBASE_API_KEY`
   - `messagingSenderId` → `FIREBASE_MESSAGING_SENDER_ID`
   - `appId` → `FIREBASE_APP_ID`

##### 5.7 Verifikasi Setup Firebase

**a. Test Koneksi Database**
```bash
# Di direktori API_Manajemen_Barang_Hilang
node -e "const admin = require('firebase-admin'); const serviceAccount = { projectId: process.env.FIREBASE_PROJECT_ID, clientEmail: process.env.FIREBASE_CLIENT_EMAIL, privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') }; admin.initializeApp({ credential: admin.credential.cert(serviceAccount) }); console.log('Firebase connected successfully!');"
```

**b. Test Firebase Storage**
1. Upload file test melalui Firebase Console
2. Verifikasi file dapat diakses
3. Test upload melalui API endpoint

**c. Test Authentication**
1. Buat user test melalui Firebase Console
2. Test login melalui aplikasi
3. Verifikasi token JWT

#### 6. Install Dependencies Flutter

```bash
cd ../  # Kembali ke root project
flutter pub get
```

#### 7. Jalankan Aplikasi

##### 7.1 Jalankan Backend API
```bash
cd API_Manajemen_Barang_Hilang
npm start
```

Server akan berjalan di: `http://localhost:3000`

##### 7.2 Jalankan AI Matching Service
```bash
cd apihf-pencocokan-mbh
npm run dev
```

Service akan berjalan di: `http://localhost:3001`

##### 7.3 Jalankan Flutter App
```bash
cd ../  # Kembali ke root project
flutter run
```

##### 7.4 Verifikasi Setup

**a. Test Backend API**:
```bash
curl http://localhost:3000/api/health
```

**b. Test AI Service**:
```bash
curl http://localhost:3001/api/health
```

**c. Test Flutter App**: Buka aplikasi dan coba register/login

---

## 📋 Template File Environment

### Template .env untuk Backend (API_Manajemen_Barang_Hilang/.env)

```env
# ===========================================
# KONFIGURASI SERVER
# ===========================================
PORT=3000
NODE_ENV=development

# ===========================================
# FIREBASE ADMIN SDK
# ===========================================
# Dapatkan dari Firebase Console > Project Settings > Service Accounts
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"

# ===========================================
# FIREBASE CLIENT SDK
# ===========================================
# Dapatkan dari Firebase Console > Project Settings > General > Your apps
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef123456789

# ===========================================
# HUGGING FACE API
# ===========================================
# Dapatkan dari https://huggingface.co/settings/tokens
HUGGING_FACE_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
HUGGING_FACE_MODEL=sentence-transformers/all-MiniLM-L6-v2

# ===========================================
# DATABASE (OPSIONAL)
# ===========================================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=manajemen_barang_hilang
DB_USER=postgres
DB_PASSWORD=your_db_password

# ===========================================
# SECURITY
# ===========================================
# Generate random string untuk JWT secret
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long
API_SECRET_KEY=your_api_secret_key_here

# ===========================================
# UPLOAD CONFIGURATION
# ===========================================
MAX_FILE_SIZE=5242880  # 5MB dalam bytes
UPLOAD_PATH=./uploads
ALLOWED_FILE_TYPES=image/jpeg,image/png,image/jpg

# ===========================================
# EMAIL CONFIGURATION (OPSIONAL)
# ===========================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# ===========================================
# RATE LIMITING
# ===========================================
RATE_LIMIT_WINDOW_MS=900000  # 15 menit
RATE_LIMIT_MAX_REQUESTS=100   # Max 100 requests per window
```

### Template .env.local untuk AI Service (apihf-pencocokan-mbh/.env.local)

```env
# ===========================================
# HUGGING FACE CONFIGURATION
# ===========================================
# Token yang sama dengan backend
HUGGING_FACE_API_KEY=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
HUGGING_FACE_MODEL=sentence-transformers/all-MiniLM-L6-v2
HUGGING_FACE_ENDPOINT=https://api-inference.huggingface.co

# ===========================================
# API CONFIGURATION
# ===========================================
# URL backend API
API_BASE_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3000

# ===========================================
# SECURITY
# ===========================================
API_SECRET_KEY=your_api_secret_key_here
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long

# ===========================================
# AI MATCHING CONFIGURATION
# ===========================================
# Threshold untuk similarity matching (0.0 - 1.0)
MATCHING_THRESHOLD=0.7
# Maximum results to return
MAX_MATCHING_RESULTS=10
# Cache duration in seconds
CACHE_DURATION=3600

# ===========================================
# DEVELOPMENT
# ===========================================
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
```

### Template untuk Flutter (lib/src/config/app_config.dart)

```dart
class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String aiServiceUrl = 'http://localhost:3001';
  
  // Untuk Android Emulator gunakan: 'http://10.0.2.2:3000'
  // Untuk iOS Simulator gunakan: 'http://127.0.0.1:3000'
  
  // Hugging Face Configuration
  static const String hfToken = 'hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  static const String hfModel = 'sentence-transformers/all-MiniLM-L6-v2';
  
  // App Configuration
  static const String appName = 'Manajemen Barang Hilang';
  static const String appVersion = '1.0.0';
  
  // File Upload Configuration
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Matching Configuration
  static const double matchingThreshold = 0.7;
  static const int maxMatchingResults = 10;
}
```

---

## 🔧 Checklist Setup Environment

### ✅ Checklist Backend (.env)

- [ ] File `.env` dibuat di `API_Manajemen_Barang_Hilang/`
- [ ] `PORT` dan `NODE_ENV` dikonfigurasi
- [ ] `FIREBASE_PROJECT_ID` diisi dengan project ID Firebase
- [ ] `FIREBASE_CLIENT_EMAIL` diisi dengan service account email
- [ ] `FIREBASE_PRIVATE_KEY` diisi dengan private key (format lengkap)
- [ ] `FIREBASE_API_KEY` diisi dengan web API key
- [ ] `FIREBASE_MESSAGING_SENDER_ID` diisi
- [ ] `FIREBASE_APP_ID` diisi
- [ ] `JWT_SECRET` diisi dengan string random yang kuat
- [ ] `HUGGING_FACE_TOKEN` diisi dengan token yang valid

### ✅ Checklist AI Service (.env.local)

- [ ] File `.env.local` dibuat di `apihf-pencocokan-mbh/`
- [ ] `HUGGING_FACE_API_KEY` diisi dengan token yang sama
- [ ] `API_BASE_URL` menunjuk ke backend API
- [ ] `API_SECRET_KEY` dikonfigurasi

### ✅ Checklist Flutter

- [ ] `flutter pub get` berhasil dijalankan
- [ ] File `matching_service.dart` diupdate dengan token HF
- [ ] URL API di service files sesuai dengan backend
- [ ] Permissions di `android/app/src/main/AndroidManifest.xml` lengkap

### ✅ Checklist Firebase

- [ ] Project Firebase dibuat
- [ ] Authentication Email/Password diaktifkan
- [ ] Firestore Database dibuat (test mode)
- [ ] Firebase Storage diaktifkan
- [ ] Service Account Key didownload
- [ ] Web App dikonfigurasi
- [ ] Test koneksi berhasil

### ✅ Checklist Hugging Face

- [ ] Akun Hugging Face dibuat
- [ ] Access Token digenerate dengan role "Read"
- [ ] Token diverifikasi dengan curl test
- [ ] Token dikonfigurasi di semua service

---

## 🚨 Troubleshooting Setup

### Masalah Environment Variables

**Problem**: `Error: Missing environment variable`

**Solution**:
1. Pastikan file `.env` ada di direktori yang benar
2. Restart server setelah mengubah `.env`
3. Periksa format variabel (tidak ada spasi di sekitar `=`)
4. Untuk `FIREBASE_PRIVATE_KEY`, pastikan menggunakan tanda kutip ganda

**Problem**: `Firebase Admin SDK initialization failed`

**Solution**:
1. Periksa format `FIREBASE_PRIVATE_KEY`:
   ```env
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY_HERE\n-----END PRIVATE KEY-----\n"
   ```
2. Pastikan `FIREBASE_PROJECT_ID` dan `FIREBASE_CLIENT_EMAIL` benar
3. Verifikasi service account memiliki permission yang cukup

### Masalah Hugging Face Token

**Problem**: `401 Unauthorized` saat mengakses Hugging Face API

**Solution**:
1. Verifikasi token dengan:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" https://huggingface.co/api/whoami
   ```
2. Pastikan token dimulai dengan `hf_`
3. Regenerate token jika perlu
4. Periksa quota dan rate limit

**Problem**: `Model not found` error

**Solution**:
1. Pastikan model `sentence-transformers/all-MiniLM-L6-v2` tersedia
2. Coba model alternatif: `sentence-transformers/all-mpnet-base-v2`
3. Periksa koneksi internet

### Masalah Firebase Setup

**Problem**: `Permission denied` saat akses Firestore

**Solution**:
1. Periksa Firestore Rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
2. Pastikan user sudah login
3. Verifikasi JWT token valid

**Problem**: `Storage upload failed`

**Solution**:
1. Periksa Firebase Storage Rules
2. Verifikasi file size tidak melebihi limit
3. Pastikan format file didukung

### Masalah Flutter

**Problem**: `SocketException: Failed host lookup`

**Solution**:
1. Pastikan backend API berjalan
2. Periksa URL API di service files
3. Untuk Android emulator, gunakan `10.0.2.2` instead of `localhost`
4. Untuk iOS simulator, gunakan `127.0.0.1`

**Problem**: `Permission denied` untuk camera/storage

**Solution**:
1. Tambahkan permissions di `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   ```
2. Untuk iOS, tambahkan di `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>App needs camera access to take photos</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>App needs photo library access</string>
   ```

### Tips Debugging

1. **Enable Verbose Logging**:
   ```env
   NODE_ENV=development
   DEBUG=*
   ```

2. **Check Server Logs**:
   ```bash
   # Backend API
   cd API_Manajemen_Barang_Hilang
   npm run dev  # Jika ada script dev dengan nodemon
   
   # AI Service
   cd apihf-pencocokan-mbh
   npm run dev
   ```

3. **Flutter Debug Mode**:
   ```bash
   flutter run --verbose
   flutter logs
   ```

4. **Test API Endpoints**:
   ```bash
   # Test health check
   curl http://localhost:3000/api/health
   
   # Test authentication
   curl -X POST http://localhost:3000/api/auth/login \
        -H "Content-Type: application/json" \
        -d '{"email":"test@example.com","password":"password"}'
   ```

## 🌐 Konfigurasi API

### URL API
- **Production**: `https://api-manajemen-barang-hilang.vercel.app/api`
- **Local Development**: `http://localhost:3000/api`

### Endpoints Utama

#### Autentikasi
- `POST /api/login` - Login pengguna
- `POST /api/register` - Registrasi pengguna baru
- `GET /api/users/profile` - Profil pengguna
- `PUT /api/users/profile` - Update profil

#### Manajemen Laporan
- `GET /api/laporan` - Ambil semua laporan
- `POST /api/laporan` - Buat laporan baru
- `GET /api/laporan/user/:userId` - Laporan berdasarkan user
- `PUT /api/laporan/:id/status` - Update status laporan
- `DELETE /api/laporan/:id` - Hapus laporan

#### Sistem Pencocokan
- `GET /api/cocok` - Ambil semua data pencocokan
- `POST /api/cocok` - Buat pencocokan baru
- `GET /api/cocok/:id` - Detail pencocokan
- `PUT /api/cocok/:id/status` - Update status pencocokan

#### Sistem Klaim
- `POST /api/klaim` - Submit klaim barang
- `GET /api/klaim` - Ambil semua klaim
- `GET /api/klaim/:id` - Detail klaim
- `PUT /api/klaim/:id/status` - Update status klaim

#### Master Data
- `GET /api/kategori` - Daftar kategori barang
- `GET /api/lokasi` - Daftar lokasi
- `GET /api/users` - Daftar pengguna (admin only)

### Konfigurasi di Flutter
Untuk mengubah URL API, edit file berikut:
- `lib/src/services/auth_service.dart`
- `lib/src/services/report_service.dart`
- `lib/src/services/matching_service.dart`
- `lib/src/services/klaim_service.dart`

## 🔒 Fitur Keamanan

- **JWT Authentication**: Sistem autentikasi berbasis JSON Web Token
- **Secure Storage**: Token disimpan dengan aman menggunakan Flutter Secure Storage
- **Role-based Authorization**: Kontrol akses berdasarkan peran pengguna
- **Input Validation**: Validasi lengkap pada semua form input
- **Error Handling**: Penanganan error yang komprehensif
- **File Upload Security**: Validasi tipe dan ukuran file
- **API Rate Limiting**: Pembatasan request untuk mencegah abuse
- **Data Encryption**: Enkripsi data sensitif
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

## 🔧 Troubleshooting

### Masalah Umum

#### 1. Laporan User Tidak Muncul
Jika laporan yang dibuat user tidak muncul di halaman riwayat:

**Solusi:**
1. **Periksa konsistensi userId**: Pastikan `userId` yang digunakan untuk menyimpan dan mengambil laporan konsisten
2. **Gunakan `userData['id']`**: Dalam `add_report_screen.dart`, pastikan menggunakan `userData['id']` sebagai `userId`
3. **Restart aplikasi**: Setelah melakukan perubahan, restart aplikasi

```dart
final userData = await _authService.getUserData();
final userId = userData['id']; // Gunakan 'id', bukan 'email'
```

#### 2. Notifikasi Tidak Muncul
Jika notifikasi tidak muncul setelah status laporan berubah:

**Solusi:**
1. **Periksa userId**: Pastikan `userId` konsisten antara laporan dan notifikasi
2. **Restart aplikasi**: Tutup dan buka kembali aplikasi untuk refresh data
3. **Periksa status laporan**: Notifikasi hanya muncul untuk perubahan status tertentu
4. **Clear cache**: Hapus data aplikasi jika diperlukan

#### 3. AI Matching Tidak Berfungsi
Jika fitur pencocokan otomatis tidak bekerja:

**Solusi:**
1. **Periksa Hugging Face Token**: Pastikan token valid dan tidak expired
2. **Cek koneksi internet**: Pastikan device terhubung ke internet
3. **Periksa threshold**: Sesuaikan nilai `_similarityThreshold` di `matching_service.dart`
4. **Cek log error**: Lihat console untuk error message dari API Hugging Face

#### 4. Upload Gambar Gagal
Jika upload gambar tidak berhasil:

**Solusi:**
1. **Periksa permission**: Pastikan app memiliki permission kamera dan storage
2. **Cek ukuran file**: Pastikan ukuran gambar tidak melebihi batas maksimal
3. **Periksa format file**: Pastikan format gambar didukung (JPG, PNG)
4. **Cek koneksi**: Pastikan koneksi internet stabil

#### 5. Login/Register Gagal
Jika autentikasi tidak berhasil:

**Solusi:**
1. **Periksa kredensial**: Pastikan email dan password benar
2. **Cek Firebase config**: Pastikan konfigurasi Firebase sudah benar
3. **Periksa API endpoint**: Pastikan backend API berjalan
4. **Clear app data**: Hapus data aplikasi dan coba lagi

### Error Codes

| Error Code | Deskripsi | Solusi |
|------------|-----------|--------|
| 401 | Unauthorized | Token expired, silakan login ulang |
| 403 | Forbidden | Tidak memiliki permission untuk aksi ini |
| 404 | Not Found | Data tidak ditemukan |
| 500 | Server Error | Masalah pada server, coba lagi nanti |
| Network Error | Koneksi gagal | Periksa koneksi internet |

### Tips Debugging

1. **Enable Debug Mode**: Jalankan app dalam debug mode untuk melihat log detail
2. **Check Console**: Selalu periksa console untuk error message
3. **Test API**: Gunakan Postman untuk test endpoint API secara manual
4. **Clear Cache**: Hapus cache aplikasi jika mengalami masalah data
5. **Update Dependencies**: Pastikan semua package Flutter up-to-date

## 📱 Fitur Tambahan

### 🎨 UI/UX Features
- **Modern Design**: Desain modern dengan Material Design 3
- **Dark/Light Theme**: Dukungan tema gelap dan terang
- **Responsive Layout**: Layout yang responsif untuk berbagai ukuran layar
- **Smooth Animations**: Animasi yang halus dan natural
- **Custom Icons**: Ikon kustom dengan SVG
- **Loading States**: Indikator loading yang informatif
- **Empty States**: Tampilan kosong yang user-friendly

### 🔍 Search & Filter
- **Global Search**: Pencarian global di semua laporan
- **Advanced Filter**: Filter berdasarkan kategori, lokasi, tanggal
- **Sort Options**: Pengurutan berdasarkan tanggal, status, relevance
- **Search History**: Riwayat pencarian
- **Quick Filters**: Filter cepat untuk akses mudah

### 📊 Analytics & Reporting
- **Dashboard Statistics**: Statistik laporan di dashboard
- **Report Analytics**: Analisis performa laporan
- **User Activity**: Tracking aktivitas pengguna
- **Success Rate**: Tingkat keberhasilan pencocokan
- **Export Data**: Export data laporan ke CSV/PDF

### 🌐 Offline Support
- **Offline Mode**: Aplikasi dapat berjalan tanpa internet
- **Data Sync**: Sinkronisasi data ketika online kembali
- **Cache Management**: Manajemen cache yang efisien
- **Offline Indicators**: Indikator status koneksi

## 🤝 Kontribusi

### Cara Berkontribusi
1. **Fork repository** ini ke akun GitHub Anda
2. **Clone** repository yang sudah di-fork
   ```bash
   git clone https://github.com/your-username/Manajemen-barang-hilang-Tekmob-DPSI-.git
   ```
3. **Buat branch** fitur baru
   ```bash
   git checkout -b feature/amazing-feature
   ```
4. **Commit** perubahan Anda
   ```bash
   git commit -m 'Add some amazing feature'
   ```
5. **Push** ke branch
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Buat Pull Request** dengan deskripsi yang jelas

### Guidelines Kontribusi
- Ikuti coding standards yang ada
- Tulis komentar yang jelas dan informatif
- Test fitur baru sebelum submit PR
- Update dokumentasi jika diperlukan
- Gunakan commit message yang deskriptif

### Code Style
- Gunakan **camelCase** untuk variabel dan function
- Gunakan **PascalCase** untuk class names
- Indentasi menggunakan 2 spaces
- Maksimal 80 karakter per baris
- Gunakan trailing commas untuk parameter

## 📄 Lisensi

Project ini menggunakan lisensi **MIT**. Lihat file `LICENSE` untuk detail lebih lanjut.

## 👥 Tim Pengembang

### Core Team
- **Project Manager**: DPSI Team Lead
- **Mobile Developer**: Flutter Specialist
- **Backend Developer**: Node.js/Express Expert
- **AI Engineer**: Machine Learning Specialist
- **UI/UX Designer**: Design System Expert
- **DevOps Engineer**: Infrastructure Specialist

### Contributors
- **Quality Assurance**: Testing Team
- **Documentation**: Technical Writers
- **Security Audit**: Security Team

## 📞 Support & Contact

- **Email**: support@manajemen-barang-hilang.com
- **GitHub Issues**: [Report Bug](https://github.com/username/Manajemen-barang-hilang-Tekmob-DPSI-/issues)
- **Documentation**: [Wiki](https://github.com/username/Manajemen-barang-hilang-Tekmob-DPSI-/wiki)
- **Discussions**: [GitHub Discussions](https://github.com/username/Manajemen-barang-hilang-Tekmob-DPSI-/discussions)

## 🏆 Acknowledgments

- **Flutter Team** untuk framework yang luar biasa
- **Firebase** untuk backend infrastructure
- **Hugging Face** untuk AI/ML capabilities
- **Material Design** untuk design guidelines
- **Open Source Community** untuk inspirasi dan dukungan

---

**Catatan**: Aplikasi ini dikembangkan sebagai bagian dari project **DPSI (Desain dan Pemrograman Sistem Informasi)** dengan fokus pada implementasi teknologi modern untuk solusi manajemen barang hilang yang efektif dan user-friendly.

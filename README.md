# TaskFlow

**TaskFlow** adalah aplikasi manajemen tugas berbasis Mobile (Android/iOS) yang dibangun menggunakan Flutter dan Firebase. Aplikasi ini dirancang untuk memenuhi syarat **Mobile Programming Final Project**. 

TaskFlow menawarkan antarmuka yang modern, bersih (clean UI/UX), dan fungsionalitas CRUD (Create, Read, Update, Delete) yang diintegrasikan langsung dengan sinkronisasi *real-time* dari **Firebase Cloud Firestore** dan sistem autentikasi dari **Firebase Authentication**.

---

## Fitur Utama

- **Autentikasi Pengguna (Firebase Auth)**
  - Register akun baru dengan email dan password.
  - Login dengan validasi keamanan.
  - Logout sesi pengguna yang aman.
  - Proteksi rute (hanya pengguna login yang bisa melihat dashboard).

- **Manajemen Tugas (CRUD Firestore)**
  - **Create**: Tambah tugas baru lengkap dengan Kategori (Personal/Work/Study) dan Tanggal Tenggat Waktu (*Due Date*).
  - **Read**: Menampilkan daftar tugas milik pengguna secara *real-time* langsung dari Firestore.
  - **Update**: Edit detail tugas atau tandai tugas sebagai Selesai / Belum Selesai (Checklist).
  - **Delete**: Hapus tugas menggunakan tombol aksi (*Pop-up Menu*) atau gestur geser (*Swipe-to-delete*).

- **Fitur Ekstra & UI/UX**
  - **Pencarian (Search Bar)**: Cari tugas spesifik berdasarkan judul atau deskripsinya secara *real-time*.
  - **Filter**: Saring tampilan daftar berdasarkan status (Semua / Aktif / Selesai).
  - **Material 3 Design**: Komponen desain modern, bersih, warna yang konsisten, dan memanjakan mata.
  - **Animasi**: Transisi masuk (Fade/Slide), animasi centang (*checkbox*), dan tab interaktif.
  - **Custom App Icon**: Menggunakan *launcher icon* khusus yang menonjolkan branding TaskFlow.

---

## Struktur Folder Proyek

Proyek ini menggunakan *Clean Architecture* sederhana yang memisahkan antara *User Interface* (UI) dan logika (*Logic*):

```text
lib/
│
├── models/             # Representasi data dan fungsi konversi Firestore (TaskModel)
├── screens/            # Halaman-halaman UI utama
│   ├── auth/           # Login Page & Register Page
│   ├── home/           # Home Page (Dashboard Daftar Tugas & Search)
│   └── task/           # Task Form Page (Form Create/Edit Tugas)
│
├── services/           # Logika interaksi dengan backend Firebase
│   ├── auth_service.dart     # Logika Register, Login, Logout
│   └── database_service.dart # Logika CRUD Firestore
│
├── utils/              # Pengaturan konstanta (Warna, Tipografi) & Validasi
│   ├── constants.dart
│   └── validators.dart
│
├── widgets/            # Komponen UI yang digunakan berulang (Reusable)
│   ├── custom_text_field.dart
│   └── task_card.dart
│
├── app.dart            # Pengaturan Tema (Theme) & Routing Berbasis Auth State
└── main.dart           # Titik masuk utama (Entry point) dan inisialisasi Firebase
```

---

## Tech Stack & Persyaratan Instalasi

Aplikasi ini dibuat menggunakan:
* **Flutter SDK**: `^3.10.1` (Gunakan versi yang kompatibel)
* **Dart**: Bahasa pemrograman utama
* **Firebase Core, Auth, & Cloud Firestore**: Sebagai *Backend as a Service (BaaS)*

### Cara Menjalankan Proyek secara Lokal

1. Pastikan Anda telah menginstal [Flutter](https://docs.flutter.dev/get-started/install) di mesin Anda.
2. Lakukan clone pada repositori ini:
   ```bash
   git clone https://github.com/Anang-Programmer/TaskFlow-Flutter.git
   cd project_android_pathway
   ```
3. Unduh semua *dependencies*:
   ```bash
   flutter pub get
   ```
4. Hubungkan perangkat fisik Android/iOS atau jalankan Emulator.
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```
*(Catatan: File `google-services.json` dan `firebase_options.dart` sudah disertakan di dalam repo ini khusus untuk keperluan penilaian kakak kakak core team agar aplikasi dapat langsung dijalankan (plug-and-play) tanpa perlu mengatur ulang proyek Firebase).*

---

### Penilaian
Proyek ini diharapkan memenuhi seluruh kriteria penilaian akhir meliputi: Fungsionalitas penuh, Kualitas Kode, Desain UI/UX, Struktur Proyek, dan Dokumentasi ini. 

Dibuat oleh Jaka Perdana untuk Mobile Programming Final Project - GDGoC USU 2025.

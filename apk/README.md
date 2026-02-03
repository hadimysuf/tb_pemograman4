# Event Organizer (Flutter)

## Deskripsi
Aplikasi Flutter ini dipakai untuk mengelola event pribadi. Alur utamanya:
register / login -> dapat token -> CRUD event -> lihat status event.
Semua data event disimpan di backend (Node + SQLite) dan diakses lewat API.

## Fitur Utama (Ringkas)
- Auth (register, login, logout)
- Home dashboard (ringkasan & daftar event + gambar)
- Event CRUD (tambah, edit, hapus)
- Profile (lihat & edit profil, ganti password)

## Penjelasan Per File (Flutter)

### lib/main.dart
- Entry point aplikasi.
- Memanggil `ApiService.loadToken()` untuk mengisi header Authorization jika token tersimpan.
- Menetapkan `AppTheme.lightTheme()` sebagai tema global.
- Halaman awal diarahkan ke `LandingScreen` supaya flow login/register jelas.

### lib/utils/app_config.dart
- Menyimpan konfigurasi API.
- `baseUrl` dipakai oleh semua request (Dio).

### lib/utils/app_theme.dart
- Tema global aplikasi (warna, app bar, tombol, input, bottom nav).
- Membuat warna utama biru konsisten di seluruh halaman.

### lib/utils/image_utils.dart
- Helper untuk menampilkan gambar event.
- Jika gambar berbentuk base64 (`data:image/...`) -> dirender dengan `Image.memory`.
- Jika bukan base64 (path lokal), gunakan `Image.file`.
- Jika tidak ada gambar -> tampil placeholder.

### lib/services/api_service.dart
- Wrapper utama untuk HTTP request menggunakan **Dio**.
- Menyimpan token JWT ke `SharedPreferences` dan memasang header Authorization.
- Endpoint penting:
  - `login()` -> POST `/auth/login`
  - `register()` -> POST `/auth/register`
  - `getEvents()` -> GET `/events`
  - `addEvent()` -> POST `/events`
  - `updateEvent()` -> PUT `/events/:id`
  - `deleteEvent()` -> DELETE `/events/:id`
  - `getProfile()` -> GET `/users/me`
  - `updateProfile()` -> PUT `/users/me`
  - `changePassword()` -> PUT `/users/me/password`

### lib/models/event_model.dart
- Model data Event untuk UI.
- Menyediakan:
  - `fromJson()` untuk parsing data dari backend.
  - `getStatus()` untuk menghitung status event (belum dimulai / berlangsung / selesai).
  - `timeRange` untuk format waktu di UI.

### lib/screens/landing_screen.dart
- Halaman awal dengan deskripsi aplikasi.
- Tombol menuju Login & Register.

### lib/screens/login_screen.dart
- Form login (email & password).
- Validasi format email dan minimal 8 karakter password.
- Jika login sukses -> navigasi ke `BottomNavbar`.

### lib/screens/register_screen.dart
- Form register (nama, email, password).
- Validasi input.
- Memanggil `ApiService.register()`.

### lib/screens/home_screen.dart
- Dashboard utama.
- Mengambil event dari backend via `ApiService.getEvents()`.
- Menampilkan:
  - Ringkasan total event & event berlangsung.
  - List event sedang berlangsung, terdekat, dan semua event.
  - Gambar event dari base64.

### lib/screens/event_screen.dart
- Menampilkan semua event dari backend.
- Floating action button untuk tambah event.
- Tap item -> ke `EventDetailScreen`.

### lib/screens/add_event_screen.dart
- Form tambah event.
- Bisa pilih gambar (file picker) -> diubah ke base64.
- Mengirim data ke endpoint `/events`.

### lib/screens/edit_event_screen.dart
- Form edit event.
- Bisa ganti gambar (file picker) -> base64.
- Mengirim update ke endpoint `/events/:id`.

### lib/screens/event_detail_screen.dart
- Detail event + gambar.
- Tombol edit & hapus.
- Edit -> ke `EditEventScreen`.
- Delete -> panggil API delete.

### lib/screens/profile_screen.dart
- Menampilkan data profil (GET `/users/me`).
- Edit profil (PUT `/users/me`).
- Ganti password (PUT `/users/me/password`).
- Logout (hapus token + kembali ke login).

### lib/widgets/bottom_navbar.dart
- Navigasi tab bawah (Home, Event, Profil).
- Menjaga state halaman yang sedang aktif.

## Konfigurasi API
Base URL API diset di:
```
lib/utils/app_config.dart
```
Contoh:
```
static const String baseUrl = 'https://eo.sadap.io/api';
```

## Catatan Teknis
- Gambar event dikirim sebagai **Base64** di field `image`.
- Backend harus menerima payload besar (limit body dinaikkan).

## Cara Jalankan
1) Pastikan backend sudah jalan.
2) Jalankan Flutter:
```
flutter run
```
3) Login / Register, lalu coba tambah event.
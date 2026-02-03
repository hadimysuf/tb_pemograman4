# Event Organizer (Flutter)

## Deskripsi
Aplikasi Flutter ini dipakai untuk mengelola event pribadi. Alur utamanya:
pengguna **register / login**, lalu bisa **membuat event**, **mengubah**, **menghapus**,
dan melihat **status event** secara otomatis (belum dimulai, sedang berlangsung, selesai).
Semua data event disimpan di backend (Node + SQLite) dan diakses lewat API.

## Fitur Utama (dengan penjelasan)

### 1) Auth (Register, Login, Logout)
- **Register**: pengguna membuat akun baru (name, email, password) ke endpoint backend.
- **Login**: setelah login sukses, backend mengirim **JWT token**. Token disimpan di
  `SharedPreferences` agar bisa digunakan untuk request berikutnya.
- **Logout**: token dihapus dari local storage sehingga request berikutnya tidak bisa
  mengakses endpoint yang dilindungi.

### 2) Home Dashboard
Home menampilkan ringkasan dan daftar event:
- **Ringkasan**: jumlah total event dan jumlah event yang sedang berlangsung.
- **Daftar event**:
  - Sedang Berlangsung
  - Event Terdekat (maksimal 3 event yang akan datang)
  - Semua Event
- **Gambar event** ditampilkan jika ada (disimpan di backend sebagai base64).

Cara perhitungan status event:
- Dibandingkan dengan waktu sekarang.
- `Belum Dimulai`: waktu sekarang < waktu mulai.
- `Sedang Berlangsung`: waktu sekarang di antara waktu mulai dan selesai.
- `Selesai`: waktu sekarang > waktu selesai.

### 3) Event (CRUD)
- **List event**: mengambil data dari endpoint `/events`.
- **Tambah event**:
  - Mengisi judul, tanggal, jam mulai, jam selesai.
  - Bisa memilih gambar dari galeri.
  - Gambar diubah ke **base64** lalu dikirim ke backend.
- **Edit event**:
  - Mengubah data event.
  - Bisa mengganti gambar.
  - Jika gambar tidak diganti, maka data gambar lama tetap dipakai.
- **Hapus event**: menghapus event berdasarkan id.

### 4) Profile
- **Lihat profil**: data profil diambil dari endpoint `/users/me`.
- **Edit profil**: update name & email lewat API.
- **Ganti password**:
  - Input password lama + password baru + konfirmasi.
  - Validasi minimal 8 karakter.
  - Jika cocok, akan request ke endpoint `/users/me/password`.
- **Logout**: membersihkan token lokal dan kembali ke halaman login.

## Struktur Folder (Ringkas)
```
lib/
  models/           -> Model data (EventModel)
  screens/          -> UI halaman (Home, Event, Login, Register, Profile)
  services/         -> API service (Dio + token)
  utils/            -> Config, theme, helper image
  widgets/          -> Komponen reusable (BottomNavbar)
```

## Alur Data API
1) **Login/Register** -> dapat token
2) Token disimpan -> dipakai di semua request berikutnya
3) Event diambil dari backend -> ditampilkan di Home & Event
4) Update/Delete -> kirim request -> refresh list

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
- **Gambar event dikirim sebagai Base64** di field `image`.
- Pastikan backend bisa menerima payload besar (limit body dinaikkan).
- Jika menggunakan HP fisik, backend harus bisa diakses dari jaringan yang sama atau lewat tunnel (devenv/NGINX).

## Cara Jalankan (Singkat)
1) Pastikan backend sudah jalan.
2) Jalankan Flutter:
```
flutter run
```
3) Login / Register, lalu coba tambah event.
# Event Organizer (Flutter)

## Deskripsi
Aplikasi Flutter untuk mengelola event. Pengguna bisa register, login, membuat event, mengedit, menghapus, dan melihat status event.

## Fitur Utama
- **Auth**: Register, Login, Logout (JWT token).
- **Home Dashboard**:
  - Ringkasan total event & event berlangsung.
  - Daftar event sedang berlangsung, terdekat, dan semua event.
  - Menampilkan gambar event.
- **Event**:
  - List event dari backend.
  - Tambah event (judul, tanggal, jam mulai & selesai, gambar).
  - Edit event (update data + gambar).
  - Hapus event.
- **Profile**:
  - Lihat profil (nama & email).
  - Edit profil (nama & email).
  - Ganti password.
  - Logout.

## Konfigurasi API
Base URL API diset di:
```
lib/utils/app_config.dart
```

## Catatan
- Gambar event dikirim dalam format **Base64** (field `image`).
- Pastikan backend sudah jalan dan bisa diakses dari device.

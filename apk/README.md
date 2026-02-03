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

## Kode Lengkap per File (lib/)

### lib/main.dart
```dart
$(Get-Content -Raw .\apk\lib\main.dart)
```

### lib/models/event_model.dart
```dart
$(Get-Content -Raw .\apk\lib\models\event_model.dart)
```

### lib/screens/add_event_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\add_event_screen.dart)
```

### lib/screens/edit_event_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\edit_event_screen.dart)
```

### lib/screens/event_detail_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\event_detail_screen.dart)
```

### lib/screens/event_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\event_screen.dart)
```

### lib/screens/home_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\home_screen.dart)
```

### lib/screens/landing_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\landing_screen.dart)
```

### lib/screens/login_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\login_screen.dart)
```

### lib/screens/profile_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\profile_screen.dart)
```

### lib/screens/register_screen.dart
```dart
$(Get-Content -Raw .\apk\lib\screens\register_screen.dart)
```

### lib/services/api_service.dart
```dart
$(Get-Content -Raw .\apk\lib\services\api_service.dart)
```

### lib/utils/app_config.dart
```dart
$(Get-Content -Raw .\apk\lib\utils\app_config.dart)
```

### lib/utils/app_theme.dart
```dart
$(Get-Content -Raw .\apk\lib\utils\app_theme.dart)
```

### lib/utils/image_utils.dart
```dart
$(Get-Content -Raw .\apk\lib\utils\image_utils.dart)
```

### lib/widgets/bottom_navbar.dart
```dart
$(Get-Content -Raw .\apk\lib\widgets\bottom_navbar.dart)
```

## Konfigurasi API
Base URL API diset di:
```
lib/utils/app_config.dart
```

## Catatan Teknis
- Gambar event dikirim sebagai **Base64** di field `image`.
- Backend harus menerima payload besar (limit body dinaikkan).
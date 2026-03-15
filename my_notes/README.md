# myNotes

Aplikasi catatan berbasis Flutter dengan Firebase sebagai backend.

## Dokumentasi

Dokumentasi lengkap codebase tersedia di folder [`docs/`](docs/README.md):

- [`docs/README.md`](docs/README.md) – Gambaran umum, arsitektur, layanan, views, dan testing
- [`docs/solid_principles.md`](docs/solid_principles.md) – Penerapan prinsip SOLID pada codebase

## Fitur

- Autentikasi email/password dengan Firebase Auth
- Verifikasi email & reset password
- Buat, edit, hapus catatan secara real-time (Firestore)
- Berbagi catatan via native share sheet
- State management dengan BLoC pattern
- Mendukung Android, iOS, Web, macOS, Windows, dan Linux

## Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

## Menjalankan Test

```bash
flutter test
```


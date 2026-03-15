# myNotes – Dokumentasi Codebase

> **Bahasa**: Dart / Flutter  
> **Versi Flutter SDK**: ≥ 3.10.4  
> **Platform**: Android, iOS, Web, macOS, Windows, Linux

---

## Daftar Isi

1. [Gambaran Umum](#gambaran-umum)
2. [Struktur Direktori](#struktur-direktori)
3. [Arsitektur Aplikasi](#arsitektur-aplikasi)
4. [Prinsip SOLID yang Diterapkan](solid_principles.md)
5. [Layanan (Services)](#layanan-services)
6. [State Management – BLoC](#state-management--bloc)
7. [Tampilan (Views)](#tampilan-views)
8. [Utilitas](#utilitas)
9. [Pengujian (Testing)](#pengujian-testing)
10. [Konfigurasi & Setup](#konfigurasi--setup)

---

## Gambaran Umum

**myNotes** adalah aplikasi catatan berbasis Flutter yang menggunakan Firebase sebagai backend. Pengguna dapat:

- Mendaftar dan masuk menggunakan email & password.
- Memverifikasi email sebelum dapat mengakses catatan.
- Membuat, mengedit, menghapus, dan berbagi catatan secara real-time.
- Menyetel ulang password melalui email.

---

## Struktur Direktori

```
my_notes/
├── docs/                          ← Dokumentasi proyek
│   ├── README.md                  ← Dokumen utama (file ini)
│   └── solid_principles.md        ← Penjelasan penerapan SOLID
├── lib/
│   ├── constants/
│   │   └── routes.dart            ← Konstanta nama rute navigasi
│   ├── enums/
│   │   └── menu_action.dart       ← Enum tindakan menu (logout, dst.)
│   ├── extensions/
│   │   └── list/
│   │       └── filter.dart        ← Extension Stream<List<T>> untuk filter
│   ├── helpers/
│   │   └── loading/
│   │       ├── loading_screen.dart           ← Overlay loading (singleton)
│   │       └── loading_screen_controller.dart ← Kontrol tampilan loading
│   ├── services/
│   │   ├── auth/
│   │   │   ├── auth_exceptions.dart          ← Kelas exception autentikasi
│   │   │   ├── auth_provider.dart            ← Interface abstrak AuthProvider
│   │   │   ├── auth_service.dart             ← Wrapper yang mendelegasi ke provider
│   │   │   ├── auth_user.dart                ← Model pengguna (immutable)
│   │   │   ├── firebase_auth_provider.dart   ← Implementasi Firebase Auth
│   │   │   └── bloc/
│   │   │       ├── auth_bloc.dart            ← BLoC autentikasi
│   │   │       ├── auth_event.dart           ← Event-event autentikasi
│   │   │       └── auth_state.dart           ← State-state autentikasi
│   │   ├── cloud/
│   │   │   ├── cloud_note.dart               ← Model CloudNote
│   │   │   ├── cloud_storage.dart            ← Interface abstrak CloudStorage
│   │   │   ├── cloud_storage_constants.dart  ← Konstanta field Firestore
│   │   │   ├── cloud_storage_exceptions.dart ← Exception penyimpanan cloud
│   │   │   └── firebase_cloud_storage.dart   ← Implementasi Firestore (singleton)
│   │   └── crud/
│   │       ├── crud_exception.dart           ← Exception CRUD lokal (tidak aktif)
│   │       └── notes_service.dart            ← Layanan SQLite lokal (tidak aktif)
│   ├── utilities/
│   │   ├── auth/
│   │   │   └── auth_error_messages.dart      ← Pemetaan pesan error autentikasi
│   │   ├── dialogs/
│   │   │   ├── generic_dialog.dart           ← Dialog generik yang dapat digunakan ulang
│   │   │   ├── error_dialog.dart             ← Dialog pesan error
│   │   │   ├── delete_dialog.dart            ← Dialog konfirmasi hapus
│   │   │   ├── logout_dialog.dart            ← Dialog konfirmasi logout
│   │   │   ├── cannot_share_empty_note_dialog.dart ← Dialog validasi berbagi catatan
│   │   │   └── loading_dialog.dart           ← Dialog loading
│   │   └── generics/
│   │       └── get_arguments.dart            ← Extension untuk mengambil argumen rute
│   ├── views/
│   │   ├── splash_view.dart                  ← Layar splash
│   │   ├── login_view.dart                   ← Layar login
│   │   ├── register_view.dart                ← Layar registrasi
│   │   ├── email_verify_view.dart            ← Layar verifikasi email
│   │   ├── forgot_password_view.dart         ← Layar lupa password
│   │   └── notes/
│   │       ├── notes_view.dart               ← Layar daftar catatan
│   │       ├── notes_list_view.dart          ← Widget daftar catatan (reusable)
│   │       └── create_update_note_view.dart  ← Layar buat/edit catatan
│   ├── firebase_options.dart                 ← Konfigurasi Firebase per platform
│   └── main.dart                             ← Entry point aplikasi
├── test/
│   ├── auth_test.dart             ← Uji unit AuthService & AuthBloc
│   ├── share_button_test.dart     ← Uji widget tombol share
│   ├── generic_dialog_test.dart   ← Uji widget dialog generik
│   └── splash_screen_test.dart    ← Uji integrasi layar splash
├── pubspec.yaml                   ← Dependensi & konfigurasi proyek
└── analysis_options.yaml          ← Konfigurasi linter
```

---

## Arsitektur Aplikasi

Aplikasi mengikuti pola **Clean Architecture** dengan tiga lapisan utama:

```
┌─────────────────────────────────┐
│          Views (UI)             │  ← Menampilkan state, mengirim event
├─────────────────────────────────┤
│       BLoC (State Mgmt)         │  ← Memproses event → menghasilkan state
├─────────────────────────────────┤
│   Services / Repositories       │  ← Komunikasi dengan Firebase
└─────────────────────────────────┘
```

### Alur Autentikasi

```
App Start
    │
    ▼
AuthEventInitialize
    │
    ├─ user == null ──────────────► AuthStateLoggedOut ──► LoginView
    │
    ├─ !user.isEmailVerified ────► AuthStateNeedsVerification ──► EmailVerifyView
    │
    └─ user.isEmailVerified ─────► AuthStateLoggedIn ──► NotesView
```

### Alur Catatan (CRUD)

```
NotesView
    │
    ├─ Baca ──────► allNotes(ownerUserId) → Stream<Iterable<CloudNote>>
    │                                         (real-time dari Firestore)
    │
    ├─ Buat ──────► [+] button → CreateUpdateNoteView → createNewNote()
    │
    ├─ Edit ──────► tap ListTile → CreateUpdateNoteView → updateNote()
    │
    └─ Hapus ─────► [delete] icon → showDeleteDialog → deleteNote()
```

---

## Layanan (Services)

### Auth Services (`lib/services/auth/`)

| File | Tanggung Jawab |
|------|----------------|
| `auth_provider.dart` | Interface abstrak – mendefinisikan kontrak autentikasi |
| `firebase_auth_provider.dart` | Implementasi konkret menggunakan Firebase Auth |
| `auth_service.dart` | Wrapper/delegator – lapisan tipis di atas `AuthProvider` |
| `auth_user.dart` | Model `AuthUser` (immutable) dengan factory dari Firebase User |
| `auth_exceptions.dart` | Kelas-kelas exception autentikasi yang spesifik |

**Prinsip DIP**: `AuthService` bergantung pada `AuthProvider` (abstrak), bukan pada `FirebaseAuthProvider` (konkret).

### Cloud Storage Services (`lib/services/cloud/`)

| File | Tanggung Jawab |
|------|----------------|
| `cloud_storage.dart` | Interface abstrak – mendefinisikan CRUD + stream catatan |
| `firebase_cloud_storage.dart` | Implementasi konkret menggunakan Firestore (singleton) |
| `cloud_note.dart` | Model `CloudNote` dengan factory dari Firestore snapshot |
| `cloud_storage_constants.dart` | Konstanta nama field Firestore |
| `cloud_storage_exceptions.dart` | Exception penyimpanan cloud yang spesifik |

**Prinsip DIP**: `NotesView` dan `CreateUpdateNoteView` bergantung pada `CloudStorage` (abstrak), bukan langsung ke `FirebaseCloudStorage`.

---

## State Management – BLoC

### Event → State Mapping

```
AuthEventInitialize        → AuthStateUninitialized → (async) → AuthStateLoggedIn / AuthStateLoggedOut
AuthEventLogin             → AuthStateLoggedOut(isLoading: true) → AuthStateLoggedIn / error
AuthEventLogout            → AuthStateLoggedOut
AuthEventRegister          → AuthStateNeedsVerification / AuthStateRegistering(exception)
AuthEventSendEmailVerification → emit(state)  (tidak mengubah state)
AuthEventShouldRegister    → AuthStateRegistering
AuthEventShouldResetPassword → AuthStateForgotPassword
AuthEventResetPassword     → AuthStateForgotPassword(isLoading) → hasSentEmail / exception
```

### State Classes

| State | Ditampilkan Di |
|-------|----------------|
| `AuthStateUninitialized` | `SplashView` |
| `AuthStateLoggedOut` | `LoginView` |
| `AuthStateRegistering` | `RegisterView` |
| `AuthStateNeedsVerification` | `EmailVerifyView` |
| `AuthStateForgotPassword` | `ForgotPasswordView` |
| `AuthStateLoggedIn` | `NotesView` |

---

## Tampilan (Views)

### `main.dart`

- **`MainApp`** (`StatelessWidget`): Mengatur tema, `MaterialApp`, dan menginisiasi `AuthBloc`.
- **`HomePage`** (`StatefulWidget`): Mengirim `AuthEventInitialize` sekali di `initState()`, lalu merutekan berdasarkan `AuthState` menggunakan `BlocConsumer`.

### Auth Views

| View | Widget Type | Deskripsi |
|------|-------------|-----------|
| `SplashView` | `StatelessWidget` | Logo dan nama aplikasi |
| `LoginView` | `StatefulWidget` | Form login dengan listener error |
| `RegisterView` | `StatefulWidget` | Form registrasi dengan listener error |
| `EmailVerifyView` | `StatelessWidget` | Prompt verifikasi email + tombol kirim ulang |
| `ForgotPasswordView` | `StatefulWidget` | Form reset password |

### Notes Views

| View | Widget Type | Deskripsi |
|------|-------------|-----------|
| `NotesView` | `StatefulWidget` | Daftar catatan real-time via `StreamBuilder` |
| `NotesListView` | `StatelessWidget` | Widget daftar catatan (reusable, menerima callback) |
| `CreateUpdateNoteView` | `StatefulWidget` | Editor catatan dengan sinkronisasi otomatis |

---

## Utilitas

### `utilities/auth/auth_error_messages.dart`

Fungsi-fungsi terpusat untuk memetakan exception autentikasi ke pesan yang ramah pengguna:

- `loginErrorMessage(Exception? error)` – untuk `LoginView`
- `registerErrorMessage(Exception? exception)` – untuk `RegisterView`

### `utilities/dialogs/`

Dialog-dialog generik yang dapat digunakan ulang:

- `showGenericDialog<T>()` – builder dialog generik
- `showErrorDialog()` – menampilkan pesan error
- `showDeleteDialog()` – konfirmasi hapus (mengembalikan `bool`)
- `showLogoutDialog()` – konfirmasi logout (mengembalikan `bool`)
- `showCannotShareEmptyNoteDialog()` – validasi catatan kosong sebelum berbagi

### `helpers/loading/`

- `LoadingScreen` (singleton): Menampilkan overlay loading di atas konten layar.
- `LoadingScreenController`: Menyimpan callback `close` dan `update` untuk overlay.

### `extensions/list/filter.dart`

Extension `StreamListFilter<T>` pada `Stream<List<T>>` yang menyediakan metode `.filter(predicate)` untuk memfilter isi list dalam stream.

### `utilities/generics/get_arguments.dart`

Extension `GetArguments` pada `BuildContext` yang menyediakan metode `.getArgument<T>()` untuk mengambil argumen navigasi dengan type-safe.

---

## Pengujian (Testing)

Semua file test berada di folder `test/`:

| File | Tipe Uji | Apa yang Diuji |
|------|----------|----------------|
| `auth_test.dart` | Unit + BLoC | `MockAuthProvider`, semua skenario autentikasi, alur forgot password di BLoC |
| `generic_dialog_test.dart` | Widget | `showGenericDialog` – null value, non-null value |
| `share_button_test.dart` | Widget | `CreateUpdateNoteView` – kehadiran tombol share, integrasi share plugin |
| `splash_screen_test.dart` | Widget/Integration | `HomePage` menampilkan `SplashView` saat uninitialized, menghilang setelah init |

### Menjalankan Test

```bash
flutter test
```

Untuk uji spesifik:

```bash
flutter test test/auth_test.dart
```

---

## Konfigurasi & Setup

### Dependensi Utama (`pubspec.yaml`)

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `firebase_core` | ^4.4.0 | Inisialisasi Firebase |
| `firebase_auth` | ^6.1.4 | Autentikasi email/password |
| `cloud_firestore` | ^6.1.2 | Penyimpanan catatan real-time |
| `firebase_analytics` | ^12.1.2 | Analitik penggunaan |
| `flutter_bloc` | ^9.1.1 | State management BLoC |
| `bloc` | ^9.2.0 | Core BLoC library |
| `equatable` | ^2.0.8 | Perbandingan objek berdasarkan nilai |
| `share_plus` | ^12.0.1 | Berbagi teks via native share sheet |
| `sqflite` | ^2.4.2 | SQLite lokal (tidak aktif, siap untuk offline mode) |

### Konfigurasi Firebase

File `firebase_options.dart` berisi konfigurasi per-platform yang dihasilkan oleh Firebase CLI. Firebase Project ID: `my-notes-23343035`.

### Tema Aplikasi

| Token | Warna | Hex |
|-------|-------|-----|
| Primary / AppBar | Cyprus | `#004643` |
| Scaffold Background | Cloud White | `#FAFAFA` |
| AppBar Foreground | White | `#FFFFFF` |

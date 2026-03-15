# Penerapan Prinsip SOLID pada myNotes

Dokumen ini menjelaskan bagaimana kelima prinsip SOLID diterapkan dalam codebase myNotes setelah refactor.

---

## S – Single Responsibility Principle (SRP)

> *Setiap kelas harus memiliki satu dan hanya satu alasan untuk berubah.*

### ✅ `AuthProvider` / `FirebaseAuthProvider` / `AuthService`

Masing-masing memiliki tanggung jawab yang jelas:

- **`AuthProvider`** – mendefinisikan kontrak, bukan implementasi.
- **`FirebaseAuthProvider`** – menangani semua komunikasi dengan Firebase Auth.
- **`AuthService`** – wrapper tipis yang mendelegasikan ke `AuthProvider`; memungkinkan penggantian provider tanpa mengubah kode yang memanggilnya.

### ✅ `auth_error_messages.dart`

Sebelum refactor, pemetaan exception → pesan error tersebar dan terduplikasi di `login_view.dart` dan `register_view.dart` (dengan bug duplikasi kondisi `GenericAuthException`).

Setelah refactor, logika ini dipusatkan di `utilities/auth/auth_error_messages.dart`:

```dart
// Satu tempat untuk semua pesan error login
String? loginErrorMessage(Exception? error) { ... }

// Satu tempat untuk semua pesan error registrasi
String? registerErrorMessage(Exception? exception) { ... }
```

### ✅ `EmailVerifyView` sebagai `StatelessWidget`

Sebelum refactor, `EmailVerifyView` adalah `StatefulWidget` tanpa state yang dikelola sama sekali. Ini melanggar SRP karena membawa "kemampuan memiliki state" tanpa memerlukannya.

Setelah refactor, diubah menjadi `StatelessWidget` – hanya bertanggung jawab untuk merender UI verifikasi email.

### ✅ `HomePage` sebagai `StatefulWidget`

Sebelum refactor, `HomePage` adalah `StatelessWidget` yang memanggil `context.read<AuthBloc>().add(AuthEventInitialize())` di dalam `build()`. Karena `build()` dapat dipanggil berkali-kali oleh framework, `AuthEventInitialize` dapat dikirim lebih dari sekali – ini melanggar SRP karena widget yang seharusnya hanya bertanggung jawab untuk rendering juga mengurus logika inisialisasi dengan cara yang tidak aman.

Setelah refactor, `HomePage` menjadi `StatefulWidget` dan mengirim event hanya sekali di `initState()`:

```dart
@override
void initState() {
  super.initState();
  context.read<AuthBloc>().add(const AuthEventInitialize());
}
```

---

## O – Open/Closed Principle (OCP)

> *Entitas perangkat lunak harus terbuka untuk ekstensi, tetapi tertutup untuk modifikasi.*

### ✅ `CloudStorage` Interface

Interface `CloudStorage` mendefinisikan kontrak lengkap untuk semua operasi penyimpanan catatan:

```dart
abstract class CloudStorage {
  Future<CloudNote> createNewNote({required String ownerUserId});
  Future<void> updateNote({required String documentId, required String text});
  Future<void> deleteNote({required String documentId});
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId});
}
```

Untuk menambahkan implementasi baru (misalnya `LocalSQLiteStorage` untuk mode offline), cukup buat kelas baru yang mengimplementasikan `CloudStorage` – **tanpa memodifikasi** kode UI atau BLoC yang sudah ada.

### ✅ `AuthProvider` Interface

Sama halnya dengan `CloudStorage`, `AuthProvider` memungkinkan penambahan implementasi autentikasi baru (misalnya Google Sign-In, OAuth) tanpa mengubah `AuthBloc` atau view yang sudah ada.

### ✅ `showGenericDialog<T>()`

Dialog generik ini menggunakan `optionsBuilder` sebagai callback, sehingga dialog baru dapat dibuat dengan berbagai pilihan tanpa mengubah fungsi inti:

```dart
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
})
```

---

## L – Liskov Substitution Principle (LSP)

> *Objek dari kelas turunan harus dapat menggantikan objek dari kelas dasar tanpa mengubah kebenaran program.*

### ✅ `CloudStorage` digunakan secara konsisten

Sebelum refactor, `NotesView` menggunakan tipe konkret `FirebaseCloudStorage`:

```dart
// ❌ Sebelum refactor – bergantung pada konkret
late final FirebaseCloudStorage _notesService;
```

Ini berarti `allNotes()` hanya tersedia melalui tipe konkret karena tidak didefinisikan di interface. Jika `FirebaseCloudStorage` diganti dengan implementasi lain, kode akan gagal kompilasi.

Setelah refactor, `NotesView` bergantung pada abstrak `CloudStorage`:

```dart
// ✅ Setelah refactor – bergantung pada abstrak
late final CloudStorage _notesService;
```

Dan `allNotes()` kini merupakan bagian dari interface, sehingga **setiap** implementasi `CloudStorage` dapat disubstitusi tanpa masalah.

### ✅ `MockAuthProvider` dalam test

`MockAuthProvider` di `test/auth_test.dart` mengimplementasikan `AuthProvider` sepenuhnya, dan dapat digunakan di `AuthBloc` tanpa memerlukan perubahan apapun pada kelas BLoC – membuktikan LSP bekerja.

---

## I – Interface Segregation Principle (ISP)

> *Klien tidak boleh dipaksa bergantung pada interface yang tidak mereka gunakan.*

### ✅ `CloudStorage` vs `AuthProvider`

Interface dipisahkan sesuai domain:

- `AuthProvider` – hanya operasi autentikasi (login, register, logout, dst.)
- `CloudStorage` – hanya operasi penyimpanan catatan (CRUD + stream)

Setiap view hanya bergantung pada interface yang benar-benar dibutuhkan:

- `CreateUpdateNoteView` menggunakan `CloudStorage` untuk create/update/delete.
- `NotesView` menggunakan `CloudStorage` untuk read (stream) dan delete.
- Tidak ada view yang bergantung pada kedua interface secara berlebihan.

### ✅ `LoadingScreenController`

`LoadingScreenController` hanya menyediakan dua callback yang dibutuhkan:

```dart
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreenText update;
}
```

Tidak ada method tambahan yang tidak diperlukan oleh konsumen.

---

## D – Dependency Inversion Principle (DIP)

> *Modul tingkat tinggi tidak boleh bergantung pada modul tingkat rendah. Keduanya harus bergantung pada abstraksi.*

### ✅ `NotesView` bergantung pada `CloudStorage`, bukan `FirebaseCloudStorage`

```dart
// ✅ Bergantung pada abstrak
class NotesView extends StatefulWidget {
  const NotesView({super.key, this.cloudStorage});
  final CloudStorage? cloudStorage;
  ...
}

// Implementasi konkret hanya digunakan sebagai default
_notesService = widget.cloudStorage ?? FirebaseCloudStorage();
```

Konstruksi ini memungkinkan injeksi dependensi untuk testing:

```dart
// Dalam test – tidak perlu Firebase
NotesView(cloudStorage: FakeCloudStorage())
```

### ✅ `CreateUpdateNoteView` bergantung pada `CloudStorage`

```dart
class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key, this.cloudStorage});
  final CloudStorage? cloudStorage;
  ...
}
```

### ✅ `AuthBloc` bergantung pada `AuthProvider`

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : ... {
    // Hanya menggunakan interface AuthProvider, bukan implementasi konkret
  }
}
```

`AuthBloc` tidak mengetahui apapun tentang Firebase. Ini memungkinkan penggantian implementasi provider dan pengujian unit tanpa Firebase.

---

## Ringkasan Perubahan Refactor

| Perubahan | Prinsip SOLID | Dampak |
|-----------|---------------|--------|
| Tambah `allNotes` ke interface `CloudStorage` | DIP, LSP | `NotesView` kini bergantung pada abstrak |
| `NotesView` gunakan `CloudStorage` (bukan `FirebaseCloudStorage`) | DIP | Testable, mudah diganti implementasi |
| `NotesView` terima `CloudStorage?` via konstruktor | DIP | Dependency injection untuk testing |
| `HomePage` jadi `StatefulWidget`, init di `initState()` | SRP | `AuthEventInitialize` dikirim tepat sekali |
| `EmailVerifyView` jadi `StatelessWidget` | SRP | Tidak membawa state yang tidak diperlukan |
| Buat `auth_error_messages.dart` | SRP, OCP | Pesan error terpusat, tidak duplikat |
| `LoginView` pakai `loginErrorMessage()` | SRP | Hapus logika pemetaan dari view |
| `RegisterView` pakai `registerErrorMessage()` | SRP | Perbaiki bug duplikasi `GenericAuthException` |
| Hapus `import 'dart:ffi'` dari `error_dialog.dart` | SRP | Hapus dependensi tidak perlu |

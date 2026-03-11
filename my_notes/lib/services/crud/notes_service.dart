// import 'dart:async';

// import 'package:my_notes/extensions/list/filter.dart';
// import 'package:my_notes/services/crud/crud_exception.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// // ──────────────────────────────────────────────────────────────────────────────
// // Constants
// // ──────────────────────────────────────────────────────────────────────────────

// const _dbName = 'notes.db';
// const _dbVersion = 1;

// abstract final class _Tables {
//   static const user = 'user';
//   static const note = 'note';
// }

// // ──────────────────────────────────────────────────────────────────────────────
// // Data models
// // ──────────────────────────────────────────────────────────────────────────────

// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({required this.id, required this.email});

//   factory DatabaseUser.fromRow(Map<String, Object?> row) =>
//       DatabaseUser(id: row['id'] as int, email: row['email'] as String);

//   @override
//   String toString() => 'User(id: $id, email: $email)';

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) || (other is DatabaseUser && other.id == id);

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   factory DatabaseNote.fromRow(Map<String, Object?> row) => DatabaseNote(
//     id: row['id'] as int,
//     userId: row['user_id'] as int,
//     text: row['text'] as String,
//     isSyncedWithCloud: (row['is_synced_with_cloud'] as int) == 1,
//   );

//   @override
//   String toString() =>
//       'Note(id: $id, userId: $userId, isSyncedWithCloud: $isSyncedWithCloud)';

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) || (other is DatabaseNote && other.id == id);

//   @override
//   int get hashCode => id.hashCode;
// }

// // ──────────────────────────────────────────────────────────────────────────────
// // Service
// // ──────────────────────────────────────────────────────────────────────────────

// class NotesService {
//   Database? _db;
//   DatabaseUser? _user;

//   List<DatabaseNote> _cachedNotes = [];

//   final _notesStreamController =
//       StreamController<List<DatabaseNote>>.broadcast();

//   Stream<List<DatabaseNote>> get notesStream =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser == null) {
//           throw UserShouldBeSetBeforeReadingAllNotesException();
//         }
//         return note.userId == currentUser.id;
//       });

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController.onListen = () =>
//         _notesStreamController.add(_cachedNotes);
//   }
//   factory NotesService() => _shared;

//   Database get _currentDb => _db ?? (throw DatabaseIsNotOpenException());

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // noop
//     }
//   }

//   // ── Lifecycle ───────────────────────────────────────────────────────────────

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();

//     final docsDir = await getApplicationDocumentsDirectory().catchError(
//       (_) => throw UnableToGetDocumentsDirectoryException(),
//     );

//     _db = await openDatabase(
//       join(docsDir.path, _dbName),
//       version: _dbVersion,
//       onCreate: _createTables,
//     );

//     // don't attempt to cache notes here because we may not know the
//     // currently logged in user yet.  Caching will be triggered when the
//     // user is set (see getOrCreateUser).
//   }

//   Future<void> close() async {
//     final db = _db ?? (throw DatabaseIsNotOpenException());
//     await db.close();
//     _db = null;
//   }

//   // ── User operations ─────────────────────────────────────────────────────────

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final rows = await _currentDb.query(
//       _Tables.user,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (rows.isEmpty) throw CouldNotFindUserException();
//     return DatabaseUser.fromRow(rows.first);
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final normalized = email.toLowerCase();

//     final existing = await _currentDb.query(
//       _Tables.user,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [normalized],
//     );
//     if (existing.isNotEmpty) throw UserAlreadyExistsException();

//     final id = await _currentDb.insert(_Tables.user, {'email': normalized});
//     return DatabaseUser(id: id, email: normalized);
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     DatabaseUser user;
//     try {
//       user = await getUser(email: email);
//     } on CouldNotFindUserException {
//       user = await createUser(email: email);
//     }

//     if (setAsCurrentUser) {
//       _user = user;
//       // once the current user is known, refresh the cache so any existing
//       // notes stored in the database are pushed to listeners
//       await _cacheNotes();
//     }

//     return user;
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final count = await _currentDb.delete(
//       _Tables.user,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (count == 0) throw CouldNotDeleteUserException();
//   }

//   // ── Note operations ─────────────────────────────────────────────────────────

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final rows = await _currentDb.query(
//       _Tables.note,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (rows.isEmpty) throw CouldNotFindNoteException();

//     final note = DatabaseNote.fromRow(rows.first);
//     _updateCache(note);
//     return note;
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes({
//     required DatabaseUser owner,
//   }) async {
//     await _ensureDbIsOpen();
//     final rows = await _currentDb.query(
//       _Tables.note,
//       where: 'user_id = ?',
//       whereArgs: [owner.id],
//     );
//     return rows.map(DatabaseNote.fromRow);
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final verified = await getUser(email: owner.email);
//     if (verified != owner) throw CouldNotFindUserException();

//     final id = await _currentDb.insert(_Tables.note, {
//       'user_id': owner.id,
//       'text': '',
//       'is_synced_with_cloud': 1,
//     });

//     final note = DatabaseNote(
//       id: id,
//       userId: owner.id,
//       text: '',
//       isSyncedWithCloud: true,
//     );

//     _updateCache(note);
//     return note;
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final count = await _currentDb.update(
//       _Tables.note,
//       {'text': text, 'is_synced_with_cloud': 0},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//     if (count == 0) throw CouldNotUpdateNoteException();

//     final updated = await getNote(id: note.id);
//     _updateCache(updated);
//     return updated;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final count = await _currentDb.delete(
//       _Tables.note,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (count == 0) throw CouldNotDeleteNoteException();

//     _cachedNotes.removeWhere((note) => note.id == id);
//     _notesStreamController.add(_cachedNotes);
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final count = await _currentDb.delete(_Tables.note);
//     _cachedNotes.clear();
//     _notesStreamController.add(_cachedNotes);
//     return count;
//   }

//   // ── Private helpers ─────────────────────────────────────────────────────────

//   void _updateCache(DatabaseNote note) {
//     _cachedNotes
//       ..removeWhere((n) => n.id == note.id)
//       ..add(note);
//     _notesStreamController.add(_cachedNotes);
//   }

//   /// Load notes for the current user into the in‑memory cache.
//   ///
//   /// When the service is first opened we don't yet know which user will be
//   /// viewing the notes, so this method is *not* called from [open]. Instead
//   /// callers should invoke it after [getOrCreateUser] has set [_user].  If
//   /// [_user] is null the cache is cleared and an empty list will be emitted.
//   Future<void> _cacheNotes() async {
//     if (_user == null) {
//       _cachedNotes = [];
//       _notesStreamController.add(_cachedNotes);
//       return;
//     }

//     final owner = _user!;
//     _cachedNotes = (await getAllNotes(owner: owner)).toList();
//     _notesStreamController.add(_cachedNotes);
//   }

//   Future<void> _createTables(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE ${_Tables.user} (
//         id    INTEGER PRIMARY KEY AUTOINCREMENT,
//         email TEXT    NOT NULL UNIQUE
//       );
//     ''');

//     await db.execute('''
//       CREATE TABLE ${_Tables.note} (
//         id                   INTEGER PRIMARY KEY AUTOINCREMENT,
//         user_id              INTEGER NOT NULL REFERENCES ${_Tables.user}(id),
//         text                 TEXT,
//         is_synced_with_cloud INTEGER NOT NULL DEFAULT 0
//       );
//     ''');
//   }
// }

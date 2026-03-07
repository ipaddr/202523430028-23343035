import 'package:my_notes/services/crud/crud_exception.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// ------------------------------------------------------------------
/// table names
/// ------------------------------------------------------------------

class _Tables {
  static const user = 'user';
  static const note = 'note';
}

/// ------------------------------------------------------------------
/// data models
/// ------------------------------------------------------------------

class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  factory DatabaseUser.fromRow(Map<String, Object?> row) =>
      DatabaseUser(id: row['id'] as int, email: row['email'] as String);

  @override
  String toString() => 'User(id: $id, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DatabaseUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final String text;
  final int userId;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.text,
    required this.userId,
    required this.isSyncedWithCloud,
  });

  factory DatabaseNote.fromRow(Map<String, Object?> row) {
    return DatabaseNote(
      id: row['id'] as int,
      text: row['text'] as String,
      userId: row['user_id'] as int,
      isSyncedWithCloud: (row['is_synced_with_cloud'] as int) == 1,
    );
  }

  @override
  String toString() =>
      'Note(id: $id, userId: $userId, synced: $isSyncedWithCloud)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DatabaseNote && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// ------------------------------------------------------------------
/// service
/// ------------------------------------------------------------------

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    final docsDir = await getApplicationDocumentsDirectory().catchError(
      (_) => throw UnableToGetDocumentsDirectoryException(),
    );
    final path = join(docsDir.path, 'notes.db');

    _db = await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> close() async {
    final db = _db ?? (throw DatabaseIsNotOpenException());
    await db.close();
    _db = null;
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _currentDb;
    final normalized = email.toLowerCase();
    final existing = await db.query(
      _Tables.user,
      limit: 1,
      where: 'email = ?',
      whereArgs: [normalized],
    );
    if (existing.isNotEmpty) throw UserAlreadyExistsException();

    final userId = await db.insert(_Tables.user, {'email': normalized});
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _currentDb;
    final results = await db.query(
      _Tables.user,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) throw CouldNotFindUserException();
    return DatabaseUser.fromRow(results.first);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _currentDb;
    final count = await db.delete(
      _Tables.user,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (count == 0) throw CouldNotDeleteUserException();
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _currentDb;
    final existing = await getUser(email: owner.email);
    if (existing != owner) throw CouldNotFindUserException();

    const text = '';
    final noteId = await db.insert(_Tables.note, {
      'user_id': owner.id,
      'text': text,
      'is_synced_with_cloud': 1,
    });

    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _currentDb;
    final notes = await db.query(
      _Tables.note,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) throw CouldNotFindNoteException();
    return DatabaseNote.fromRow(notes.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes({
    required DatabaseUser owner,
  }) async {
    final db = _currentDb;
    final rows = await db.query(
      _Tables.note,
      where: 'user_id = ?',
      whereArgs: [owner.id],
    );
    return rows.map(DatabaseNote.fromRow);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _currentDb;
    final count = await db.update(
      _Tables.note,
      {'text': text, 'is_synced_with_cloud': 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (count == 0) throw CouldNotUpdateNoteException();
    return getNote(id: note.id);
  }

  Future<int> deleteAllNotes() async {
    final db = _currentDb;
    return db.delete(_Tables.note);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _currentDb;
    final count = await db.delete(
      _Tables.note,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count == 0) throw CouldNotDeleteNoteException();
  }

  Database get _currentDb => _db ?? (throw DatabaseIsNotOpenException());

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${_Tables.user} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE
      );
    ''');

    await db.execute('''
      CREATE TABLE ${_Tables.note} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES ${_Tables.user}(id),
        text TEXT,
        is_synced_with_cloud INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }
}

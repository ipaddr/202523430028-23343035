import 'package:flutter_test/flutter_test.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage_exceptions.dart';

void main() {
  group('CloudNote', () {
    test('constructor stores all fields', () {
      final note = CloudNote(
        documentId: 'doc1',
        ownerUserId: 'user1',
        text: 'Hello, world!',
      );

      expect(note.documentId, 'doc1');
      expect(note.ownerUserId, 'user1');
      expect(note.text, 'Hello, world!');
    });

    test('two notes with different IDs are not identical', () {
      final a = CloudNote(documentId: 'a', ownerUserId: 'u', text: 't');
      final b = CloudNote(documentId: 'b', ownerUserId: 'u', text: 't');

      expect(a.documentId, isNot(equals(b.documentId)));
    });

    test('text can be empty string', () {
      final note = CloudNote(documentId: 'id', ownerUserId: 'uid', text: '');
      expect(note.text, isEmpty);
    });
  });

  group('CloudStorageExceptions', () {
    test('CouldNotCreateNoteException is a CloudStorageExceptions', () {
      expect(
        CouldNotCreateNoteException(),
        isA<CloudStorageExceptions>(),
      );
    });

    test('CouldNotUpdateNoteException is a CloudStorageExceptions', () {
      expect(
        CouldNotUpdateNoteException(),
        isA<CloudStorageExceptions>(),
      );
    });

    test('CouldNotDeleteNoteException is a CloudStorageExceptions', () {
      expect(
        CouldNotDeleteNoteException(),
        isA<CloudStorageExceptions>(),
      );
    });

    test('CouldNotGetAllNotesException is a CloudStorageExceptions', () {
      expect(
        CouldNotGetAllNotesException(),
        isA<CloudStorageExceptions>(),
      );
    });
  });

  group('FakeCloudStorage (in-memory implementation)', () {
    late _FakeCloudStorage storage;

    setUp(() {
      storage = _FakeCloudStorage();
    });

    test('createNewNote returns a note with the correct ownerUserId', () async {
      final note = await storage.createNewNote(ownerUserId: 'u1');
      expect(note.ownerUserId, 'u1');
      expect(note.text, isEmpty);
      expect(note.documentId, isNotEmpty);
    });

    test('updateNote changes the stored text', () async {
      final note = await storage.createNewNote(ownerUserId: 'u1');
      await storage.updateNote(documentId: note.documentId, text: 'updated');
      final stored = storage.notes[note.documentId];
      expect(stored?.text, 'updated');
    });

    test('deleteNote removes the note', () async {
      final note = await storage.createNewNote(ownerUserId: 'u1');
      await storage.deleteNote(documentId: note.documentId);
      expect(storage.notes.containsKey(note.documentId), isFalse);
    });

    test('allNotes stream emits notes for the correct owner only', () async {
      await storage.createNewNote(ownerUserId: 'u1');
      await storage.createNewNote(ownerUserId: 'u1');
      await storage.createNewNote(ownerUserId: 'u2');

      final notes = await storage.allNotes(ownerUserId: 'u1').first;
      expect(notes.length, 2);
      expect(notes.every((n) => n.ownerUserId == 'u1'), isTrue);
    });
  });
}

// ── In-memory fake used only by the tests in this file ──────────────────────

class _FakeCloudStorage {
  final Map<String, CloudNote> notes = {};
  int _counter = 0;

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final id = 'note_${++_counter}';
    final note = CloudNote(documentId: id, ownerUserId: ownerUserId, text: '');
    notes[id] = note;
    return note;
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    final existing = notes[documentId];
    if (existing == null) throw CouldNotUpdateNoteException();
    notes[documentId] = CloudNote(
      documentId: documentId,
      ownerUserId: existing.ownerUserId,
      text: text,
    );
  }

  Future<void> deleteNote({required String documentId}) async {
    final removed = notes.remove(documentId);
    if (removed == null) throw CouldNotDeleteNoteException();
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final filtered =
        notes.values.where((n) => n.ownerUserId == ownerUserId).toList();
    return Stream.value(filtered);
  }
}

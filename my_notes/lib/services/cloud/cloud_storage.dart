import 'package:my_notes/services/cloud/cloud_note.dart';

/// Abstract interface for note storage implementations.
///
/// Depending on this abstraction (rather than concrete classes like
/// [FirebaseCloudStorage]) keeps the UI layer decoupled from any specific
/// back-end, satisfying the Dependency-Inversion Principle.  It also allows
/// lightweight fakes to be injected during widget tests without touching
/// Firebase.
///
/// All write operations are separated from the read stream so that the caller
/// only sees one well-defined contract regardless of the underlying storage
/// technology.
abstract class CloudStorage {
  /// Creates a new, empty note owned by [ownerUserId].
  ///
  /// Returns the persisted [CloudNote] so callers can immediately reference
  /// its [CloudNote.documentId].
  ///
  /// Throws a [CouldNotCreateNoteException] if the operation fails.
  Future<CloudNote> createNewNote({required String ownerUserId});

  /// Replaces the [text] of the note identified by [documentId].
  ///
  /// Throws a [CouldNotUpdateNoteException] if the note does not exist or the
  /// update cannot be applied.
  Future<void> updateNote({
    required String documentId,
    required String text,
  });

  /// Permanently removes the note identified by [documentId].
  ///
  /// Throws a [CouldNotDeleteNoteException] if the note does not exist or the
  /// deletion fails.
  Future<void> deleteNote({required String documentId});

  /// A live stream of all notes belonging to [ownerUserId].
  ///
  /// The stream emits a new [Iterable] every time the underlying data changes.
  /// Callers should not close the stream themselves — it is managed by the
  /// storage implementation.
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId});
}

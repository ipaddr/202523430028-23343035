import 'package:my_notes/services/cloud/cloud_note.dart';

/// An abstract interface for note storage implementations.
///
/// This allows the UI layers to depend on a simple contract instead of the
/// concrete Firebase implementation, which makes widget testing easier as
/// we can provide fakes that don't talk to Firestore.
abstract class CloudStorage {
  /// Creates a new note for [ownerUserId].
  Future<CloudNote> createNewNote({required String ownerUserId});

  /// Updates the text of an existing note.
  Future<void> updateNote({
    required String documentId,
    required String text,
  });

  /// Deletes a note by its document ID.
  Future<void> deleteNote({required String documentId});

  /// Returns a real-time stream of all notes belonging to [ownerUserId].
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId});
}

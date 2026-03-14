import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage.dart';
import 'package:my_notes/services/cloud/cloud_storage_constants.dart';
import 'package:my_notes/services/cloud/cloud_storage_exceptions.dart';

/// Firebase Firestore implementation of [CloudStorage].
///
/// This class is a singleton — use the default [FirebaseCloudStorage()]
/// factory constructor to obtain the shared instance.  All Firestore
/// documents are stored in the `notes` collection.
///
/// Follows the Dependency-Inversion Principle: callers depend on
/// [CloudStorage], not on this concrete class.
class FirebaseCloudStorage implements CloudStorage {
  /// The Firestore collection that holds all note documents.
  final notes = FirebaseFirestore.instance.collection('notes');

  // ── CloudStorage implementation ────────────────────────────────────────────

  /// {@macro cloud_storage.create_new_note}
  ///
  /// Adds a document with an empty [noteField] and the given [ownerUserId],
  /// then fetches it back to confirm it was stored.
  @override
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdField: ownerUserId,
      noteField: '',
    });

    final fetchedNote = await document.get();

    if (fetchedNote.data() == null) {
      throw CouldNotCreateNoteException();
    }

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  /// {@macro cloud_storage.update_note}
  @override
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({noteField: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  /// {@macro cloud_storage.delete_note}
  @override
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  /// {@macro cloud_storage.all_notes}
  ///
  /// Uses a Firestore `where` query so only documents owned by
  /// [ownerUserId] are returned.  The stream is driven by Firestore's
  /// real-time listener, so it re-emits whenever any matching document
  /// changes.
  @override
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes
          .where(ownerUserIdField, isEqualTo: ownerUserId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );

  // ── Singleton ──────────────────────────────────────────────────────────────

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();

  /// Returns the shared [FirebaseCloudStorage] singleton.
  factory FirebaseCloudStorage() => _shared;
}

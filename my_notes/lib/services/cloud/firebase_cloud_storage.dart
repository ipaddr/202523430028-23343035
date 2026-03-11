import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/services/cloud/cloud_storage.dart';
import 'package:my_notes/services/cloud/cloud_storage_constants.dart';
import 'package:my_notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage implements CloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

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

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdField, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

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

  @override
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) => notes
      .where(ownerUserIdField, isEqualTo: ownerUserId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) => CloudNote.fromSnapshot(doc)),
      );

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

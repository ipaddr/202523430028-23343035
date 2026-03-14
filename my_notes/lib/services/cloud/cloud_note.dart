import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_notes/services/cloud/cloud_storage_constants.dart';

/// Immutable representation of a single note stored in the cloud.
///
/// A [CloudNote] is the data model shared between the storage layer and the UI.
/// It is intentionally kept simple — it carries only the fields needed to
/// display and edit a note.
class CloudNote {
  /// Firestore document ID that uniquely identifies this note.
  final String documentId;

  /// UID of the Firebase Auth user who owns this note.
  final String ownerUserId;

  /// Plain-text body of the note.
  final String text;

  /// Creates a [CloudNote] from individual field values.
  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  /// Creates a [CloudNote] by reading fields from a Firestore document
  /// [snapshot].
  ///
  /// Relies on [ownerUserIdField] and [noteField] constants so that the
  /// field-name mapping is defined in one place.
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      ownerUserId = snapshot.data()[ownerUserIdField] as String,
      text = snapshot.data()[noteField] as String;
}

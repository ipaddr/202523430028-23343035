/// Base class for all cloud-storage related exceptions.
///
/// Catching [CloudStorageExceptions] will catch every specialised exception
/// thrown by [FirebaseCloudStorage] while still allowing callers to
/// distinguish between specific failure modes.
class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

/// Thrown when a new note document cannot be created in the cloud.
class CouldNotCreateNoteException extends CloudStorageExceptions {}

/// Thrown when fetching the list of notes fails.
class CouldNotGetAllNotesException extends CloudStorageExceptions {}

/// Thrown when an existing note cannot be updated.
class CouldNotUpdateNoteException extends CloudStorageExceptions {}

/// Thrown when a note cannot be deleted.
class CouldNotDeleteNoteException extends CloudStorageExceptions {}

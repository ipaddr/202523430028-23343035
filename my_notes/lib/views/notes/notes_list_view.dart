import 'package:flutter/material.dart';
import 'package:my_notes/services/cloud/cloud_note.dart';
import 'package:my_notes/utilities/dialogs/delete_dialog.dart';

/// Callback signature used by [NotesListView] to notify the parent when the
/// user performs an action on a specific note.
typedef NoteCallback = void Function(CloudNote note);

/// Scrollable list that renders a collection of [CloudNote]s.
///
/// Each item shows the note text (truncated to one line), a delete button,
/// and an onTap handler — all provided by the parent via callbacks, keeping
/// this widget concerned only with presentation (Single Responsibility).
class NotesListView extends StatelessWidget {
  /// The notes to display.
  final Iterable<CloudNote> notes;

  /// Called when the user confirms deletion of a note.
  final NoteCallback onDeleteNote;

  /// Called when the user taps on a note to open it.
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
          onTap: () => onTap(note),
        );
      },
    );
  }
}

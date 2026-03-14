import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

/// Shows an informational dialog reminding the user that a note must have
/// content before it can be shared.
///
/// The dialog is dismissed when the user taps "OK".
Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Cannot Share Empty Note',
    content: 'Please add some content to the note before sharing.',
    optionsBuilder: () => {'OK': null},
  );
}

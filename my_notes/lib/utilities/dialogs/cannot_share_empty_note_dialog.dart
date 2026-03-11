import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Cannot Share Empty Note',
    content: 'Please add some content to the note before sharing.',
    optionsBuilder: () => {'OK': null},
  );
}

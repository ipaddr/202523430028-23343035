import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete note',
    content: 'Are you sure you want to delete this note?',
    optionsBuilder: () => {'Cancel': false, 'Delete': true},
  ).then((value) => value ?? false);
}

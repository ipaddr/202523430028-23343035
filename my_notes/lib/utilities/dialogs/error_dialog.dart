import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

/// Shows a modal error dialog with the given [message].
///
/// The dialog has a single "OK" button that dismisses it.  Returns a
/// [Future] that completes after the dialog is closed.
Future<void> showErrorDialog(BuildContext context, String message) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: message,
    optionsBuilder: () => {'OK': null},
  );
}

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:my_notes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showGenericDialog<Void>(
    context: context,
    title: 'An error occurred',
    content: message,
    optionsBuilder: () => {'OK': null},
  );
}

import 'package:flutter/material.dart';

/// Callback type that closes the loading dialog when invoked.
typedef CloseDialog = void Function();

/// Shows a transparent loading dialog with a [CircularProgressIndicator] and
/// a [text] label.
///
/// Returns a [CloseDialog] callback that, when called, dismisses the dialog
/// by popping the current route.
CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}

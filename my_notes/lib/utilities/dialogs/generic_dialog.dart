import 'package:flutter/material.dart';

/// Signature of the builder function that supplies the dialog button labels
/// and their associated return values.
///
/// The map key is the button label (displayed text), and the value is what
/// the dialog returns when that button is pressed.  Pass `null` as a value
/// to dismiss the dialog without returning a meaningful result.
typedef DialogOptionBuilder<T> = Map<String, T> Function();

/// Shows a generic [AlertDialog] with a [title], [content], and one or more
/// buttons built from [optionsBuilder].
///
/// Returns the value associated with the button the user tapped, or `null` if
/// the dialog was dismissed without a selection (e.g. by tapping outside or
/// pressing the system back button).
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle) {
          final optionValue = options[optionTitle];
          return TextButton(
            onPressed: () {
              if (optionValue != null) {
                Navigator.of(context).pop(optionValue);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}

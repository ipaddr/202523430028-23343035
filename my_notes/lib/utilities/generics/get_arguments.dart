import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArguments on BuildContext {
  T? getArgument<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is T) {
      return args;
    } else {
      return null;
    }
  }
}

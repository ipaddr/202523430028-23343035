import 'package:flutter/material.dart' show BuildContext, ModalRoute;

/// Extension on [BuildContext] that provides a convenient way to read typed
/// route arguments.
extension GetArguments on BuildContext {
  /// Returns the route argument cast to [T], or `null` if there is no
  /// argument or the argument is not of type [T].
  ///
  /// Example:
  /// ```dart
  /// final note = context.getArgument<CloudNote>();
  /// ```
  T? getArgument<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is T) {
      return args;
    } else {
      return null;
    }
  }
}

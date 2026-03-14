import 'package:flutter/foundation.dart';

/// Callback that closes / hides the loading overlay.
typedef CloseLoadingScreen = void Function();

/// Callback that replaces the loading overlay's message with [text].
typedef UpdateLoadingScreenText = void Function(String text);

/// Immutable handle returned by [LoadingScreen.show] / [LoadingScreen.showOverlay].
///
/// Use [close] to remove the overlay and [update] to change its message while
/// it is still visible.
@immutable
class LoadingScreenController {
  /// Removes the loading overlay from the widget tree.
  final CloseLoadingScreen close;

  /// Replaces the current message with a new [text].
  final UpdateLoadingScreenText update;

  const LoadingScreenController({required this.close, required this.update});
}

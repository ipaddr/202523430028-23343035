import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_notes/helpers/loading/loading_screen_controller.dart';

/// Singleton that manages a full-screen loading overlay.
///
/// Call [show] to display (or update) the overlay and [hide] to dismiss it.
/// Because this class is a singleton, only one overlay can be active at a
/// time; calling [show] while an overlay is already visible simply updates
/// its text via [LoadingScreenController.update].
class LoadingScreen {
  /// Returns the shared [LoadingScreen] singleton.
  factory LoadingScreen() => _shared;

  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  /// The controller for the currently-visible overlay, or `null` if no
  /// overlay is shown.
  LoadingScreenController? controller;

  /// Shows the loading overlay with the given [text].
  ///
  /// If an overlay is already visible its text is updated instead of creating
  /// a new one.
  void show({required BuildContext context, required String text}) {
    if (controller != null) {
      controller!.update(text);
    } else {
      controller = _showOverlay(context: context, text: text);
    }
  }

  /// Hides the loading overlay if it is currently visible.
  void hide() {
    controller?.close();
    controller = null;
  }

  /// Inserts a new overlay entry into the nearest [Overlay] and returns a
  /// [LoadingScreenController] to manage it.
  ///
  /// Prefer [show] over calling this method directly.
  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    StreamBuilder<String>(
                      stream: textController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    final screenController = LoadingScreenController(
      close: () {
        textController.close();
        overlay.remove();
        controller = null;
      },
      update: (text) => textController.add(text),
    );
    controller = screenController;
    return screenController;
  }
}

import 'package:flutter/foundation.dart';

typedef CloseLoadingScreen = void Function();
typedef UpdateLoadingScreenText = void Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreenText update;

  const LoadingScreenController({required this.close, required this.update});
}

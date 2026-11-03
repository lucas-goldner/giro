import 'package:flutter/foundation.dart';

/// Decides which widget flavour the app renders and which map backend is
/// available, without touching `dart:io` (which is not usable on the web).
abstract final class PlatformStyle {
  /// Forces the Cupertino look regardless of the host platform.
  ///
  /// The web preview sets this so the UI matches the iOS app. Pass
  /// `?style=material` in the URL to see the Material variant instead.
  static bool? forceCupertino;

  static bool get isCupertino =>
      forceCupertino ??
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  /// Forces the canvas-drawn mock map even on iOS/Android. Widget tests set
  /// this because the test binding pretends to be Android.
  static bool forceMockMap = false;

  /// Whether the Flutter GPU MapLibre map (maplibre_flutter_gpu) is used.
  /// It needs Flutter GPU, which exists on iOS and Android but not on the
  /// web; everywhere else (desktop, widget tests) the mock map is used.
  static bool get hasNativeMap =>
      !forceMockMap &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}

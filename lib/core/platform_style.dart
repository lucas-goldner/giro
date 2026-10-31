import 'package:flutter/foundation.dart';

/// Decides which widget flavour the app renders and whether the native map
/// plugins are available, without touching `dart:io` (which is not usable on
/// the web).
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

  /// platform_maps_flutter only ships Apple Maps and Google Maps bindings, so
  /// everywhere else (web, desktop, widget tests) the mock map is used.
  static bool get hasNativeMap =>
      !forceMockMap &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/web_mocks/mock_geolocator_platform.dart';
import 'package:giro/web_mocks/sample_data.dart';
import 'package:giro/web_mocks/web_mock_deps.dart';

/// Web preview entry point: `flutter run -d chrome -t lib/main_web.dart`.
///
/// Native-only packages are replaced by the mocks in `lib/web_mocks/`:
/// MMKV -> in-memory repositories, HealthKit -> canned workouts,
/// geolocator -> a simulated walk, platform maps -> a canvas-drawn map.
/// Append `?style=material` to the URL to preview the Material variant.
void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'Giro Web',
  );
  PlatformStyle.forceCupertino =
      Uri.base.queryParameters['style'] != 'material';
  GeolocatorPlatform.instance =
      MockGeolocatorPlatform(path: SampleData.recordingPath);

  WidgetsFlutterBinding.ensureInitialized()
    ..deferFirstFrame()
    // Keeps the semantics tree on so browser automation
    // (tool/web_screenshots.mjs) can find buttons by their labels.
    ..ensureSemantics();
  runApp(const GiroApp(loadDeps: loadWebMockDeps));
}

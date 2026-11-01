import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/web_mocks/mock_geolocator_platform.dart';
import 'package:giro/web_mocks/sample_data.dart';
import 'package:giro/web_mocks/web_mock_deps.dart';

/// Web preview entry point: `flutter run -d chrome -t lib/main_web.dart`.
///
/// Native-only packages are replaced by the mocks in `lib/web_mocks/`:
/// MMKV -> in-memory repositories, HealthKit -> canned workouts,
/// geolocator -> a simulated walk. The map is the real Google Maps
/// JavaScript map (see `web/index.html`); append `?map=mock` to use the
/// canvas-drawn mock instead, and `?style=material` to preview the Material
/// variant.
void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'Giro Web',
  );
  PlatformStyle.forceCupertino =
      Uri.base.queryParameters['style'] != 'material';
  PlatformStyle.forceMockMap = Uri.base.queryParameters['map'] == 'mock';
  // Redesign proposals (lib/redesign/):
  // `?design=journal|glass|blocks|clean|swiss|tonal|outdoor|mono|zenly|sport`.
  DesignVariant.current =
      DesignVariant.fromName(Uri.base.queryParameters['design']);
  GeolocatorPlatform.instance =
      MockGeolocatorPlatform(path: SampleData.recordingPath);

  WidgetsFlutterBinding.ensureInitialized()
    ..deferFirstFrame()
    // Keeps the semantics tree on so browser automation
    // (tool/web_screenshots.mjs) can find buttons by their labels.
    ..ensureSemantics();
  runApp(const GiroApp(loadDeps: loadWebMockDeps));
}

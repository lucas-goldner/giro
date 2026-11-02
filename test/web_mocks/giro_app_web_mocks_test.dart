import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/design/sonic/sonic_home.dart';
import 'package:giro/design/sonic/sonic_import_page.dart';
import 'package:giro/design/sonic/sonic_places_page.dart';
import 'package:giro/design/sonic/sonic_record_page.dart';
import 'package:giro/design/sonic/sonic_route_detail.dart';
import 'package:giro/design/sonic/sonic_walks_page.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/web_mocks/mock_geolocator_platform.dart';
import 'package:giro/web_mocks/mock_platform_map.dart';
import 'package:giro/web_mocks/sample_data.dart';
import 'package:giro/web_mocks/web_mock_deps.dart';

/// Boots the whole app on the web mocks (in-memory storage, canned
/// HealthKit workouts, simulated GPS, canvas map) and walks every screen.
void main() {
  setUpAll(() {
    FlavorConfig(flavor: Flavor.dev, name: 'Giro Test');
    PlatformStyle.forceCupertino = true;
    PlatformStyle.forceMockMap = true;
    GeolocatorPlatform.instance = MockGeolocatorPlatform(
      path: SampleData.recordingPath,
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // main() defers the first frame until the dependencies are loaded and
    // GiroApp releases it, so the test binding has to defer it as well.
    tester.binding.deferFirstFrame();
    // iPhone-sized surface so the whole HUD panel is on screen.
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GiroApp(loadDeps: loadWebMockDeps));
    await tester.pumpAndSettle();
  }

  testWidgets('boots on the mocks: fog map and HUD', (tester) async {
    await pumpApp(tester);

    expect(find.byType(SonicHome), findsOneWidget);
    expect(find.byType(MockPlatformMap), findsOneWidget);
    expect(find.text('GO!'), findsOneWidget);
    expect(find.text('STAGE: TOKYO · THIS WEEK'), findsOneWidget);
  });

  testWidgets('stage select lists the seeded walks and opens a result', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('All walks'));
    await tester.pumpAndSettle();
    expect(find.byType(SonicWalksPage), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Stage .* rank')),
      findsNWidgets(SampleData.walkRoutes.length),
    );

    await tester.tap(find.bySemanticsLabel(RegExp('^Stage .* rank')).first);
    await tester.pumpAndSettle();
    expect(find.byType(SonicRouteDetail), findsOneWidget);
    // The HUD text is drawn as layered copies (drop, outline, fill).
    expect(find.text('STAGE CLEAR!'), findsWidgets);
  });

  testWidgets('spot collection lists the seeded places', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Places'));
    await tester.pumpAndSettle();
    expect(find.byType(SonicPlacesPage), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Spot ')),
      findsNWidgets(SampleData.pois.length),
    );
    expect(find.bySemanticsLabel('Spot Shibuya Crossing'), findsOneWidget);
  });

  testWidgets('imports a workout from the mocked Health item box', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Import'));
    await tester.pumpAndSettle();
    expect(find.byType(SonicImportPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Load workouts'));
    await tester.pumpAndSettle();
    // Two canned workouts are new, two are already stages.
    expect(find.bySemanticsLabel(RegExp(r' workout$')), findsNWidgets(2));
    expect(
      find.bySemanticsLabel(RegExp(r'already a stage$')),
      findsNWidgets(2),
    );

    await tester.tap(find.bySemanticsLabel(RegExp(r' workout$')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Save walks'));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'already a stage$')),
      findsNWidgets(3),
    );
  });

  testWidgets('records a walk with the simulated location', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Record'));
    await tester.pumpAndSettle();
    expect(find.byType(SonicRecordPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Start recording'));
    await tester.pump();
    // The cubit samples the location every 5 seconds.
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Stop recording'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('View finished recording'), findsOneWidget);
  });
}

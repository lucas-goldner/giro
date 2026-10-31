import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/poi_management/widgets/poi_card.dart';
import 'package:giro/routes_management/widgets/route_card.dart';
import 'package:giro/web_mocks/mock_geolocator_platform.dart';
import 'package:giro/web_mocks/mock_platform_map.dart';
import 'package:giro/web_mocks/sample_data.dart';
import 'package:giro/web_mocks/web_mock_deps.dart';

void main() {
  setUpAll(() {
    FlavorConfig(flavor: Flavor.dev, name: 'Giro Test');
    PlatformStyle.forceCupertino = true;
    PlatformStyle.forceMockMap = true;
    GeolocatorPlatform.instance =
        MockGeolocatorPlatform(path: SampleData.recordingPath);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // main() defers the first frame until the dependencies are loaded and
    // GiroApp releases it, so the test binding has to defer it as well.
    tester.binding.deferFirstFrame();
    // iPhone-sized surface so the whole bottom sheet is on screen.
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GiroApp(loadDeps: loadWebMockDeps));
    await tester.pumpAndSettle();
  }

  testWidgets('boots on the web mocks and shows the mock map',
      (tester) async {
    await pumpApp(tester);

    expect(find.byType(MockPlatformMap), findsOneWidget);
    expect(find.text('Giro Test'), findsOneWidget);
    expect(find.text('View walked routes'), findsOneWidget);
  });

  testWidgets('lists the seeded routes and points of interest',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('View walked routes'));
    await tester.pumpAndSettle();
    expect(find.byType(RouteCard), findsNWidgets(SampleData.walkRoutes.length));

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Point of interests'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiCard), findsNWidgets(SampleData.pois.length));
    expect(find.text('Shibuya Crossing'), findsOneWidget);
  });

  testWidgets('records a walk with the simulated location', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Record Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start recording'));
    await tester.pump();

    // The cubit samples the location every 5 seconds.
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop recording'));
    await tester.pumpAndSettle();

    expect(find.text('View finished recording'), findsOneWidget);
  });
}

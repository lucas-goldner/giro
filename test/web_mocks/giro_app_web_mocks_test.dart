import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/design/sonic/sonic_home.dart';
import 'package:giro/design/sonic/sonic_record_page.dart';
import 'package:giro/design/sonic/sonic_route_detail.dart';
import 'package:giro/design/sonic/sonic_walks_page.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/poi_management/widgets/poi_card.dart';
import 'package:giro/redesign/design_variant.dart';
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
    GeolocatorPlatform.instance = MockGeolocatorPlatform(
      path: SampleData.recordingPath,
    );
  });

  Future<void> pumpApp(WidgetTester tester, {DesignVariant? design}) async {
    DesignVariant.current = design;
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

  testWidgets('boots on the web mocks and shows the mock map', (tester) async {
    await pumpApp(tester);

    expect(find.byType(MockPlatformMap), findsOneWidget);
    expect(find.text('Giro Test'), findsOneWidget);
    expect(find.text('View walked routes'), findsOneWidget);
  });

  testWidgets('lists the seeded routes and points of interest', (tester) async {
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

  group('Sonic design', () {
    Future<void> pumpSonic(WidgetTester tester) =>
        pumpApp(tester, design: DesignVariant.sonic);

    testWidgets('shows home, stage select and a stage result', (tester) async {
      await pumpSonic(tester);
      expect(find.byType(SonicHome), findsOneWidget);
      expect(find.text('GO!'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('All walks'));
      await tester.pumpAndSettle();
      expect(find.byType(SonicWalksPage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(RegExp('^Stage .* rank')).first);
      await tester.pumpAndSettle();
      expect(find.byType(SonicRouteDetail), findsOneWidget);
      // The HUD text is drawn as layered copies (drop, outline, fill).
      expect(find.text('STAGE CLEAR!'), findsWidgets);
    });

    testWidgets('records a walk from the HUD', (tester) async {
      await pumpSonic(tester);
      await tester.tap(find.bySemanticsLabel('Record'));
      await tester.pumpAndSettle();
      expect(find.byType(SonicRecordPage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Start recording'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 11));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Stop recording'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('View finished recording'), findsOneWidget);
    });
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/design/sonic/sonic_home.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/web_mocks/mock_geolocator_platform.dart';
import 'package:giro/web_mocks/sample_data.dart';
import 'package:giro/web_mocks/web_mock_deps.dart';

/// The app follows the device language for every supported locale and the
/// ARB files stay complete.
void main() {
  setUpAll(() {
    FlavorConfig(flavor: Flavor.dev, name: 'Giro Test');
    PlatformStyle.forceCupertino = true;
    PlatformStyle.forceMockMap = true;
    GeolocatorPlatform.instance = MockGeolocatorPlatform(
      path: SampleData.recordingPath,
    );
  });

  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    tester.binding.deferFirstFrame();
    tester.platformDispatcher.localeTestValue = locale;
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GiroApp(loadDeps: loadWebMockDeps));
    await tester.pumpAndSettle();
  }

  test('every supported language is listed and translated', () {
    const wanted = ['en', 'ja', 'zh', 'ko', 'de', 'fr', 'es', 'it', 'pt'];
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      wanted.toSet(),
    );
    final template = json.decode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final keys = template.keys.where((k) => !k.startsWith('@')).toSet();
    for (final code in wanted) {
      final arb = json.decode(
        File('lib/l10n/app_$code.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final translated = arb.keys.where((k) => !k.startsWith('@')).toSet();
      expect(translated, keys, reason: 'app_$code.arb');
      for (final key in keys) {
        expect(arb[key], isNotEmpty, reason: '$code.$key');
      }
    }
  });

  testWidgets('home speaks Japanese', (tester) async {
    await pumpApp(tester, const Locale('ja'));
    expect(find.byType(SonicHome), findsOneWidget);
    expect(find.text('ステージ: 東京 · 今週'), findsOneWidget);
    expect(find.text('GO!'), findsOneWidget);
    expect(find.textContaining('回の散歩'), findsOneWidget);
    expect(find.text('STAGE: TOKYO · THIS WEEK'), findsNothing);
  });

  testWidgets('home speaks German with a decimal comma', (tester) async {
    await pumpApp(tester, const Locale('de'));
    expect(find.text('STAGE: TOKIO · DIESE WOCHE'), findsOneWidget);
    expect(find.textContaining('Spaziergänge'), findsWidgets);
    final kilometres = find.byWidgetPredicate(
      (w) => w is Text && RegExp(r'^\d+,\d$').hasMatch(w.data ?? ''),
    );
    expect(kilometres, findsWidgets);
    // Labels for VoiceOver follow the language too.
    expect(find.bySemanticsLabel('Alle Spaziergänge'), findsOneWidget);
  });

  testWidgets('falls back to English for an unsupported language', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('nl'));
    expect(find.text('STAGE: TOKYO · THIS WEEK'), findsOneWidget);
  });
}

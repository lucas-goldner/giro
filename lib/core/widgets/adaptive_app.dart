import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/core/router.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Cupertino page transitions on iOS, Material elsewhere; the look itself is
/// the Sonic HUD on every platform.
class AdaptiveApp extends StatelessWidget {
  const AdaptiveApp({this.locale, super.key});

  /// Null follows the device language.
  final Locale? locale;

  @override
  Widget build(BuildContext context) => PlatformStyle.isCupertino
      ? CupertinoApp(
          debugShowCheckedModeBanner: FlavorConfig.isDev(),
          onGenerateRoute: generateRoutes,
          theme: const CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: SonicTheme.blue,
            scaffoldBackgroundColor: SonicTheme.navy,
          ),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        )
      : MaterialApp(
          debugShowCheckedModeBanner: FlavorConfig.isDev(),
          onGenerateRoute: generateRoutes,
          theme: SonicTheme.themeData,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
}

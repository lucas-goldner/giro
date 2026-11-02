import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/design/sonic/sonic_bootstrap.dart';
import 'package:giro/design/sonic/sonic_home.dart';
import 'package:giro/design/sonic/sonic_import_page.dart';
import 'package:giro/design/sonic/sonic_places_page.dart';
import 'package:giro/design/sonic/sonic_record_page.dart';
import 'package:giro/design/sonic/sonic_route_detail.dart';
import 'package:giro/design/sonic/sonic_walks_page.dart';

/// Named routes of the app.
abstract final class AppRoutes {
  static const String home = '/';
  static const String walks = '/walks';
  static const String walkDetail = '/walk';
  static const String places = '/places';
  static const String record = '/record';
  static const String import = '/import';
}

Route<void>? generateRoutes(RouteSettings settings) => switch (settings.name) {
  AppRoutes.walks => _adaptiveRoute(settings, const SonicWalksPage()),
  AppRoutes.walkDetail => _adaptiveRoute(
    settings,
    SonicRouteDetail(route: settings.arguments! as WalkRoute),
  ),
  AppRoutes.places => _adaptiveRoute(settings, const SonicPlacesPage()),
  AppRoutes.record => _adaptiveRoute(settings, const SonicRecordPage()),
  AppRoutes.import => _adaptiveRoute(settings, const SonicImportPage()),
  _ => _adaptiveRoute(settings, const SonicBootstrap(child: SonicHome())),
};

Route<void> _adaptiveRoute(RouteSettings settings, Widget child) =>
    PlatformStyle.isCupertino
    ? CupertinoPageRoute<void>(settings: settings, builder: (_) => child)
    : MaterialPageRoute<void>(settings: settings, builder: (_) => child);

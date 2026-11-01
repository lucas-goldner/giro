import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/map/screen/giro_map.dart';
import 'package:giro/poi_management/screen/poi_management.dart';
import 'package:giro/record_walk/screen/record_walk.dart';
import 'package:giro/redesign/blocks_home.dart';
import 'package:giro/redesign/clean/clean_home.dart';
import 'package:giro/redesign/clean/clean_route_detail.dart';
import 'package:giro/redesign/clean/clean_walks_page.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/redesign/glass_home.dart';
import 'package:giro/redesign/journal_home.dart';
import 'package:giro/redesign/redesign_bootstrap.dart';
import 'package:giro/redesign/redesign_routes_page.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:giro/routes_management/screen/routes_management.dart';

Route<void>? generateRoutes(
  RouteSettings settings,
) =>
    switch (settings.name) {
      GiroMapPage.routeName => _adaptiveRoute(settings, _home()),
      RouteManagementPage.routeName =>
        _adaptiveRoute(settings, _routesList()),
      RouteDetailPage.routeName => _adaptiveRoute(
          settings,
          _routeDetail(settings.arguments! as WalkRoute),
        ),
      POIManagementPage.routeName => _adaptiveRoute(
          settings,
          const POIManagementPage(),
        ),
      RecordWalkPage.routeName => _adaptiveRoute(
          settings,
          const RecordWalkPage(),
        ),
      _ => _adaptiveRoute(
          settings,
          _home(),
        ),
    };

/// The redesign proposals (see `lib/redesign/`) swap the home screen and the
/// walks list; everything else is shared.
Widget _home() => switch (DesignVariant.current) {
      null => const GiroMapPage(),
      DesignVariant.journal => const RedesignBootstrap(child: JournalHome()),
      DesignVariant.glass => const RedesignBootstrap(child: GlassHome()),
      DesignVariant.blocks => const RedesignBootstrap(child: BlocksHome()),
      DesignVariant.clean => const RedesignBootstrap(child: CleanHome()),
    };

Widget _routesList() => switch (DesignVariant.current) {
      null => const RouteManagementPage(),
      DesignVariant.clean => const CleanWalksPage(),
      final variant => RedesignRoutesPage(variant: variant),
    };

Widget _routeDetail(WalkRoute route) => switch (DesignVariant.current) {
      DesignVariant.clean => CleanRouteDetail(route: route),
      _ => RouteDetailPage(route),
    };

Route<void> _adaptiveRoute(RouteSettings settings, Widget child) {
  return PlatformStyle.isCupertino
      ? CupertinoPageRoute<void>(
          builder: (context) => child,
        )
      : MaterialPageRoute<void>(
          builder: (context) => child,
        );
}

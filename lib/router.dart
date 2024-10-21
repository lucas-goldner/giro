import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/map/screen/giro_map.dart';
import 'package:giro/poi_management/screen/poi_management.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:giro/routes_management/screen/routes_management.dart';

Route<void>? generateRoutes(
  RouteSettings settings,
) =>
    switch (settings.name) {
      GiroMapPage.routeName => _adaptiveRoute(settings, const GiroMapPage()),
      RouteManagementPage.routeName =>
        _adaptiveRoute(settings, const RouteManagementPage()),
      RouteDetailPage.routeName => _adaptiveRoute(
          settings,
          RouteDetailPage(settings.arguments! as WalkRoute),
        ),
      POIManagementPage.routeName => _adaptiveRoute(
          settings,
          const POIManagementPage(),
        ),
      _ => _adaptiveRoute(
          settings,
          const GiroMapPage(),
        ),
    };

Route<void> _adaptiveRoute(RouteSettings settings, Widget child) {
  return Platform.isIOS
      ? CupertinoPageRoute<void>(
          builder: (context) => child,
        )
      : MaterialPageRoute<void>(
          builder: (context) => child,
        );
}

import 'package:flutter/material.dart';
import 'package:giro/map/screen/giro_map.dart';
import 'package:giro/routes_management/screen/routes_management.dart';

MaterialPageRoute<void> generateRoutes(
  RouteSettings settings,
) =>
    switch (settings.name) {
      GiroMapPage.routeName => const GiroMapPage().route,
      RouteManagementPage.routeName => const RouteManagementPage().route,
      _ => const GiroMapPage().route
    };

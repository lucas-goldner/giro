import 'package:flutter/material.dart';
import 'package:giro/map/screen/giro_map.dart';

MaterialPageRoute<void> generateRoutes(
  RouteSettings settings,
) =>
    switch (settings.name) {
      GiroMapPage.routeName => const GiroMapPage().route,
      _ => const GiroMapPage().route
    };

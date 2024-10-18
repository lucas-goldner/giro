import 'package:flutter/material.dart';
import 'package:giro/map/widgets/giro_map.dart';

MaterialPageRoute generateRoutes(
  RouteSettings settings,
) =>
    switch (settings.name) {
      GiroMapPage.routeName => const GiroMapPage().route,
      _ => const GiroMapPage().route
    };

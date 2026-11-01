import 'package:flutter/material.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/map/screen/importer_dialog.dart';
import 'package:giro/poi_management/screen/poi_management.dart';
import 'package:giro/record_walk/screen/record_walk.dart';
import 'package:giro/routes_management/screen/routes_management.dart';

/// The navigation every redesign home screen offers, kept in one place.
abstract final class RedesignActions {
  static void record(BuildContext context) =>
      context.navigator.pushNamed(RecordWalkPage.routeName);

  static void walks(BuildContext context) =>
      context.navigator.pushNamed(RouteManagementPage.routeName);

  static void places(BuildContext context) =>
      context.navigator.pushNamed(POIManagementPage.routeName);

  static Future<void> import(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        builder: (_) => const ImporterDialogPage(),
      );
}

import 'package:flutter/widgets.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/router.dart';

/// The navigation every HUD screen offers.
abstract final class SonicActions {
  static void record(BuildContext context) =>
      context.navigator.pushNamed(AppRoutes.record);

  static void walks(BuildContext context) =>
      context.navigator.pushNamed(AppRoutes.walks);

  static void places(BuildContext context) =>
      context.navigator.pushNamed(AppRoutes.places);

  static void import(BuildContext context) =>
      context.navigator.pushNamed(AppRoutes.import);
}

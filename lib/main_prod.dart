import 'package:flutter/cupertino.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/native_deps.dart';
import 'package:giro/giro_app.dart';
import 'package:giro/redesign/design_variant.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'Giro',
  );
  DesignVariant.current = DesignVariant.sonic;
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const GiroApp(loadDeps: loadNativeDeps));
}

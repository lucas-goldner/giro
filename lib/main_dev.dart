import 'package:flutter/cupertino.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/giro_app.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'Giro Dev',
  );
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const GiroApp());
}

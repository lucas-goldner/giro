import 'package:flutter/cupertino.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/giro_app.dart';

void main() {
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'Giro',
  );
  print('Running in production mode');
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const GiroApp());
}

import 'package:map_launcher/map_launcher.dart';

abstract class LaunchableMapsRepo {
  Future<List<AvailableMap>> fetchAvailableMaps();
}

import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:map_launcher/map_launcher.dart';

class LaunchableMapsRepoImpl implements LaunchableMapsRepo {
  @override
  Future<List<AvailableMap>> fetchAvailableMaps() async {
    final maps = await MapLauncher.installedMaps;
    return maps;
  }
}

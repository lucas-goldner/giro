import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:map_launcher/map_launcher.dart';

class LaunchableMapsRepoImpl implements LaunchableMapsRepo {
  /// Map apps the app offers for launching a point of interest.
  ///
  /// map_launcher 7 no longer bundles a discovery list, so the supported
  /// providers have to be declared explicitly.
  static const supportedMaps = <MapApp>[MapApp.apple, MapApp.google];

  @override
  Future<List<AvailableMap>> fetchAvailableMaps() async {
    final maps = await MapLauncher.getAvailableMaps(supportedMaps);
    // Only offer natively installed apps, matching the previous
    // `MapLauncher.installedMaps` behaviour.
    return maps.where((map) => map.isInstalled).toList();
  }
}

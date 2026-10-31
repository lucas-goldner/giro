import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:map_launcher/map_launcher.dart';

/// On the web no map app is ever "installed", which would hide the launch
/// actions. This pretends Apple Maps and Google Maps are available; launching
/// them opens their web URLs in a new tab.
class MockLaunchableMapsRepo implements LaunchableMapsRepo {
  const MockLaunchableMapsRepo();

  @override
  Future<List<AvailableMap>> fetchAvailableMaps() async => const [
        AvailableMap(map: MapApp.apple, isInstalled: true),
        AvailableMap(map: MapApp.google, isInstalled: true),
      ];
}

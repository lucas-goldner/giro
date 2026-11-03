import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:giro/core/repository/map_settings_repo.dart';
import 'package:giro/core/repository/poi_repo.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

/// Everything the widget tree needs that depends on the platform.
///
/// Built by [AppDepsLoader]s such as `loadNativeDeps` (MMKV, HealthKit) and
/// `loadWebMockDeps` (in-memory mocks for the web preview and tests).
class AppInitDeps {
  const AppInitDeps({
    required this.walkRoutesRepo,
    required this.poiRepo,
    required this.launchableMapsRepo,
    required this.healthkitRepo,
    required this.mapSettingsRepo,
    required this.tileStore,
  });

  final WalkRoutesRepo walkRoutesRepo;
  final PoiRepo poiRepo;
  final LaunchableMapsRepo launchableMapsRepo;
  final HealthkitRepo healthkitRepo;
  final MapSettingsRepo mapSettingsRepo;
  final TileStore tileStore;
}

typedef AppDepsLoader = Future<AppInitDeps> Function();

import 'package:giro/core/model/app_init_deps.dart';
import 'package:giro/core/model/map_settings.dart';
import 'package:giro/web_mocks/in_memory_map_settings_repo.dart';
import 'package:giro/web_mocks/in_memory_poi_repo.dart';
import 'package:giro/web_mocks/in_memory_walk_routes_repo.dart';
import 'package:giro/web_mocks/mock_healthkit_repo.dart';
import 'package:giro/web_mocks/mock_launchable_maps_repo.dart';
import 'package:giro/web_mocks/mock_tile_store.dart';
import 'package:giro/web_mocks/sample_data.dart';

/// Wires the app to the in-memory and mock implementations so it can run
/// without MMKV, HealthKit or native maps (web preview, widget tests).
Future<AppInitDeps> loadWebMockDeps() async {
  final walkRoutesRepo = InMemoryWalkRoutesRepo(seed: SampleData.walkRoutes);
  await walkRoutesRepo.init();
  final poiRepo = InMemoryPoiRepo(seed: SampleData.pois);
  await poiRepo.init();

  return AppInitDeps(
    walkRoutesRepo: walkRoutesRepo,
    poiRepo: poiRepo,
    launchableMapsRepo: const MockLaunchableMapsRepo(),
    healthkitRepo: MockHealthkitRepo(workouts: SampleData.workouts),
    mapSettingsRepo: InMemoryMapSettingsRepo(
      initial: const MapSettings(mapDownloadPrompted: true),
    ),
    tileStore: MockTileStore(),
  );
}

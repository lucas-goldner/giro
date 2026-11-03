import 'dart:io';

import 'package:giro/core/map/tile_cache_http.dart';
import 'package:giro/core/model/app_init_deps.dart';
import 'package:giro/core/repository/launchable_maps_repo_impl.dart';
import 'package:giro/core/repository/map_settings_repo_mmkv_impl.dart';
import 'package:giro/core/repository/poi_repo_mmkv_impl.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/map/repository/healthkit_repo_method_channel_impl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// The real implementations used on iOS/Android. Keep this out of the web
/// entry point: MMKV relies on `dart:ffi`, which does not compile for the web.
Future<AppInitDeps> loadNativeDeps() async {
  final walkRoutesRepo = WalkRoutesRepoMmkvImpl();
  await walkRoutesRepo.init();
  final poiRepo = PoiRepoMmkvImpl();
  await poiRepo.init();
  final mapSettingsRepo = MapSettingsRepoMmkvImpl();
  await mapSettingsRepo.init();

  // OpenFreeMap asks clients for a distinctive User-Agent.
  final info = await PackageInfo.fromPlatform();
  final support = await getApplicationSupportDirectory();
  final tileStore = TileCacheHttp(
    directory: Directory('${support.path}/map_tiles'),
    userAgent: 'Giro/${info.version} (+https://github.com/lucas-goldner/giro)',
  );
  await tileStore.start();

  return AppInitDeps(
    walkRoutesRepo: walkRoutesRepo,
    poiRepo: poiRepo,
    launchableMapsRepo: LaunchableMapsRepoImpl(),
    healthkitRepo: HealthkitRepoMethodChannelImpl(),
    mapSettingsRepo: mapSettingsRepo,
    tileStore: tileStore,
  );
}

import 'package:giro/core/model/app_init_deps.dart';
import 'package:giro/core/repository/launchable_maps_repo_impl.dart';
import 'package:giro/core/repository/poi_repo_mmkv_impl.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/map/repository/healthkit_repo_method_channel_impl.dart';

/// The real implementations used on iOS/Android. Keep this out of the web
/// entry point: MMKV relies on `dart:ffi`, which does not compile for the web.
Future<AppInitDeps> loadNativeDeps() async {
  final walkRoutesRepo = WalkRoutesRepoMmkvImpl();
  await walkRoutesRepo.init();
  final poiRepo = PoiRepoMmkvImpl();
  await poiRepo.init();

  return AppInitDeps(
    walkRoutesRepo: walkRoutesRepo,
    poiRepo: poiRepo,
    launchableMapsRepo: LaunchableMapsRepoImpl(),
    healthkitRepo: HealthkitRepoMethodChannelImpl(),
  );
}

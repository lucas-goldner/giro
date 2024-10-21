import 'package:giro/core/repository/launchable_maps_repo_impl.dart';
import 'package:giro/core/repository/poi_repo_mmkv_impl.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';

class AppInitDeps {
  const AppInitDeps({
    required this.walkRoutesRepo,
    required this.poiRepo,
    required this.launchableMapsRepo,
  });

  final WalkRoutesRepoMmkvImpl walkRoutesRepo;
  final PoiRepoMmkvImpl poiRepo;
  final LaunchableMapsRepoImpl launchableMapsRepo;
}

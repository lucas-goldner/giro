import 'dart:convert';

import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:mmkv/mmkv.dart';

class WalkRoutesRepoMmkvImpl extends WalkRoutesRepo {
  late final MMKV mmkv;

  @override
  Future<void> init() async {
    await MMKV.initialize();
    mmkv = MMKV.defaultMMKV();
  }

  @override
  void addRoute(WalkRoute route) =>
      mmkv.encodeString(route.id, jsonEncode(route));

  @override
  List<WalkRoute> getRoutes() => mmkv.allKeys
      .map((key) {
        final routeJson = mmkv.decodeString(key);
        if (routeJson != null) {
          return WalkRoute.fromJson(
            jsonDecode(routeJson) as Map<String, dynamic>,
          );
        }
      })
      .whereType<WalkRoute>()
      .toList();

  @override
  void removeRouteById(String id) => mmkv.removeValue(id);
}

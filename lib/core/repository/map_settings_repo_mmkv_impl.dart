import 'dart:convert';

import 'package:giro/core/model/map_settings.dart';
import 'package:giro/core/repository/map_settings_repo.dart';
import 'package:mmkv/mmkv.dart';

class MapSettingsRepoMmkvImpl extends MapSettingsRepo {
  static const _key = 'map';

  late final MMKV _mmkv;

  @override
  Future<void> init() async {
    await MMKV.initialize();
    _mmkv = MMKV('settings');
  }

  @override
  MapSettings load() {
    final json = _mmkv.decodeString(_key);
    if (json == null) {
      return const MapSettings();
    }
    return MapSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> save(MapSettings settings) async {
    _mmkv.encodeString(_key, jsonEncode(settings.toJson()));
  }
}

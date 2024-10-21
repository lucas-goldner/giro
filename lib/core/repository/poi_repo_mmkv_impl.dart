import 'dart:convert';

import 'package:giro/core/model/poi.dart';
import 'package:giro/core/repository/poi_repo.dart';
import 'package:mmkv/mmkv.dart';

class PoiRepoMmkvImpl extends PoiRepo {
  late final MMKV mmkv;

  @override
  Future<void> init() async {
    await MMKV.initialize();
    mmkv = MMKV('pois');
  }

  @override
  void addPOI(POI poi) => mmkv.encodeString(poi.id, jsonEncode(poi));

  @override
  List<POI> getPOIs() => mmkv.allKeys
      .map((key) {
        final poiJson = mmkv.decodeString(key);
        if (poiJson != null) {
          return POI.fromJson(
            jsonDecode(poiJson) as Map<String, dynamic>,
          );
        }
      })
      .whereType<POI>()
      .toList();

  @override
  void removePOIById(String id) => mmkv.removeValue(id);

  @override
  void clearAll() => mmkv.removeValues(mmkv.allKeys);
}

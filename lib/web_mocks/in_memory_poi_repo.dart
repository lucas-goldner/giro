import 'package:giro/core/model/poi.dart';
import 'package:giro/core/repository/poi_repo.dart';

/// Replaces the MMKV-backed repository where `dart:ffi` is unavailable (web)
/// or undesirable (widget tests). Data lives for the session only.
class InMemoryPoiRepo implements PoiRepo {
  InMemoryPoiRepo({Iterable<POI> seed = const []})
      : _seed = List.unmodifiable(seed);

  final List<POI> _seed;
  final Map<String, POI> _pois = {};

  @override
  Future<void> init() async {
    _pois.clear();
    _seed.forEach(addPOI);
  }

  @override
  void addPOI(POI poi) => _pois[poi.id] = poi;

  @override
  List<POI> getPOIs() => _pois.values.toList();

  @override
  void removePOIById(String id) => _pois.remove(id);

  @override
  void clearAll() => _pois.clear();
}

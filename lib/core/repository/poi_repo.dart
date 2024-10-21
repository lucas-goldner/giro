import 'package:giro/core/model/poi.dart';

abstract class PoiRepo {
  Future<void> init();
  void addPOI(POI poi);
  void removePOIById(String id);
  List<POI> getPOIs();
  void clearAll();
}

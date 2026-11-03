import 'package:giro/core/model/map_settings.dart';

abstract class MapSettingsRepo {
  Future<void> init();
  MapSettings load();
  Future<void> save(MapSettings settings);
}

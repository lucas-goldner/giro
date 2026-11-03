import 'package:giro/core/model/map_settings.dart';
import 'package:giro/core/repository/map_settings_repo.dart';

/// Settings that live only for the session (web preview, widget tests).
class InMemoryMapSettingsRepo extends MapSettingsRepo {
  InMemoryMapSettingsRepo({MapSettings initial = const MapSettings()})
    : _settings = initial;

  MapSettings _settings;

  @override
  Future<void> init() async {}

  @override
  MapSettings load() => _settings;

  @override
  Future<void> save(MapSettings settings) async => _settings = settings;
}

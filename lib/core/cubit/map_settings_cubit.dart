import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/map_settings.dart';
import 'package:giro/core/repository/map_settings_repo.dart';

/// Holds the persisted [MapSettings] for every map in the app.
class MapSettingsCubit extends Cubit<MapSettings> {
  MapSettingsCubit(this._repo) : super(const MapSettings());

  final MapSettingsRepo _repo;

  void load() => emit(_repo.load());

  Future<void> update(MapSettings settings) async {
    emit(settings);
    await _repo.save(settings);
  }

  Future<void> setTrailWidth(double width) =>
      update(state.copyWith(trailWidth: width));

  Future<void> setRevealRadius(double meters) =>
      update(state.copyWith(revealRadiusMeters: meters));

  Future<void> markMapDownloadPrompted() =>
      update(state.copyWith(mapDownloadPrompted: true));
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/core/repository/poi_repo.dart';

part 'poi_states.dart';

class PoiCubit extends Cubit<PoiState> {
  PoiCubit(this._poiRepo) : super(const PoiInitial());

  final PoiRepo _poiRepo;

  void fetchPOIs() {
    emit(PoisLoading(state.pois));
    final pois = _poiRepo.getPOIs();
    emit(PoisLoaded([...pois]));
  }

  void addPOI(POI poi) {
    emit(PoisLoading(state.pois));
    _poiRepo.addPOI(poi);
    final pois = [...state.pois, poi];
    emit(PoisLoaded([...pois]));
  }

  /// Adds many spots with a single state change, skipping duplicates.
  void addPOIs(Iterable<POI> pois) {
    emit(PoisLoading(state.pois));
    final existing = {for (final poi in state.pois) poi.id};
    final added = <POI>[];
    for (final poi in pois) {
      if (existing.add(poi.id)) {
        _poiRepo.addPOI(poi);
        added.add(poi);
      }
    }
    emit(PoisLoaded([...state.pois, ...added]));
  }

  /// Removes every spot whose id is in [ids] with a single state change.
  void removePOIsByIds(Set<String> ids) {
    emit(PoisLoading(state.pois));
    ids.forEach(_poiRepo.removePOIById);
    emit(PoisLoaded(state.pois.where((poi) => !ids.contains(poi.id)).toList()));
  }

  void removePOI(POI poi) {
    emit(PoisLoading(state.pois));
    _poiRepo.removePOIById(poi.id);
    final pois = state.pois.where((p) => p.id != poi.id).toList();
    emit(PoisLoaded([...pois]));
  }

  void clearAll() {
    emit(PoisLoading(state.pois));
    _poiRepo.clearAll();
    emit(const PoisLoaded([]));
  }
}

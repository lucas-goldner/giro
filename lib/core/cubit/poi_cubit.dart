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

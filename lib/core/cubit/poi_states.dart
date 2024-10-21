part of 'poi_cubit.dart';

sealed class PoiState extends Equatable {
  const PoiState(this.pois);
  final List<POI> pois;

  @override
  List<Object?> get props => [pois];
}

class PoiInitial extends PoiState {
  const PoiInitial() : super(const []);
}

class PoisLoading extends PoiState {
  const PoisLoading(super.pois);
}

class PoisLoaded extends PoiState {
  const PoisLoaded(super.pois);
}

part of 'launchable_maps_cubit.dart';

sealed class LaunchableMapsState extends Equatable {
  const LaunchableMapsState(this.launchableMaps);
  final List<AvailableMap> launchableMaps;

  List<MapType> get mapTypes =>
      launchableMaps.map((map) => map.mapType).toList();

  @override
  List<Object?> get props => [launchableMaps];
}

class LaunchableMapsInitial extends LaunchableMapsState {
  const LaunchableMapsInitial() : super(const []);
}

class LaunchableMapsLoading extends LaunchableMapsState {
  const LaunchableMapsLoading(super.launchableMaps);
}

class LaunchableMapsLoaded extends LaunchableMapsState {
  const LaunchableMapsLoaded(super.launchableMaps);
}

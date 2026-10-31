part of 'launchable_maps_cubit.dart';

sealed class LaunchableMapsState extends Equatable {
  const LaunchableMapsState(this.launchableMaps);
  final List<AvailableMap> launchableMaps;

  List<MapApp> get mapApps => launchableMaps.map((map) => map.map).toList();

  bool hasMapApp(MapApp mapApp) => mapApps.any((app) => app.id == mapApp.id);

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

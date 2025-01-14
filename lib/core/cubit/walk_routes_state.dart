part of 'walk_routes_cubit.dart';

sealed class WalkRoutesState extends Equatable {
  const WalkRoutesState({required this.routes});
  final List<WalkRoute> routes;

  List<LatLng> get coordinates => routes
      .map((route) => route.coordinates)
      .expand((element) => element)
      .toList();

  List<WalkRoute> get sortedRoutes =>
      routes..sort((a, b) => b.endDate.compareTo(a.endDate));

  @override
  List<Object?> get props => [routes];
}

final class WalkRoutesStateUninitialized extends WalkRoutesState {
  const WalkRoutesStateUninitialized() : super(routes: const []);
}

final class WalkRoutesStateLoading extends WalkRoutesState {
  const WalkRoutesStateLoading(List<WalkRoute> routes) : super(routes: routes);
}

final class WalkRoutesStateLoaded extends WalkRoutesState {
  const WalkRoutesStateLoaded(List<WalkRoute> routes) : super(routes: routes);
}

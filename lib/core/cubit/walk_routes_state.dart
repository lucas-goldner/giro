part of 'walk_routes_cubit.dart';

sealed class WalkRoutesState extends Equatable {
  const WalkRoutesState({required this.routes});
  final List<WalkRoute> routes;

  @override
  List<Object?> get props => [routes];
}

final class WalkRoutesStateUninitialized extends WalkRoutesState {
  WalkRoutesStateUninitialized() : super(routes: []);
}

final class WalkRoutesStateLoaded extends WalkRoutesState {
  const WalkRoutesStateLoaded(List<WalkRoute> routes) : super(routes: routes);
}

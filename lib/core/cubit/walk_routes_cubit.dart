import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:giro/core/model/geo.dart';

part 'walk_routes_state.dart';

class WalkRoutesCubit extends Cubit<WalkRoutesState> {
  WalkRoutesCubit(this._walkRoutesRepo)
    : super(const WalkRoutesStateUninitialized());

  final WalkRoutesRepo _walkRoutesRepo;

  void fetchRoutes() {
    emit(WalkRoutesStateLoading(state.routes));
    final routes = _walkRoutesRepo.getRoutes();
    emit(WalkRoutesStateLoaded([...routes]));
  }

  void addRoute(WalkRoute route) {
    emit(WalkRoutesStateLoading(state.routes));
    _walkRoutesRepo.addRoute(route);
    emit(WalkRoutesStateLoaded([...state.routes, route]));
  }

  /// Adds many walks with a single state change.
  void addRoutes(Iterable<WalkRoute> routes) {
    emit(WalkRoutesStateLoading(state.routes));
    final existing = {for (final route in state.routes) route.id};
    final added = <WalkRoute>[];
    for (final route in routes) {
      if (existing.add(route.id)) {
        _walkRoutesRepo.addRoute(route);
        added.add(route);
      }
    }
    emit(WalkRoutesStateLoaded([...state.routes, ...added]));
  }

  /// Removes every walk whose id is in [ids] with a single state change.
  void removeRoutesByIds(Set<String> ids) {
    emit(WalkRoutesStateLoading(state.routes));
    ids.forEach(_walkRoutesRepo.removeRouteById);
    emit(
      WalkRoutesStateLoaded(
        state.routes.where((route) => !ids.contains(route.id)).toList(),
      ),
    );
  }

  void removeRoute(WalkRoute route) {
    emit(WalkRoutesStateLoading(state.routes));
    _walkRoutesRepo.removeRouteById(route.id);
    final filteredRoutes = state.routes.where((r) => r.id != route.id).toList();
    emit(WalkRoutesStateLoaded([...filteredRoutes]));
  }

  void clearAll() {
    emit(WalkRoutesStateLoading(state.routes));
    _walkRoutesRepo.clearAll();
    emit(const WalkRoutesStateLoaded([]));
  }
}

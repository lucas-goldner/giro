import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

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

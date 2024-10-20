import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';

part 'walk_routes_state.dart';

class WalkRoutesCubit extends Cubit<WalkRoutesState> {
  WalkRoutesCubit(this._walkRoutesRepo)
      : super(const WalkRoutesStateUninitialized());

  final WalkRoutesRepo _walkRoutesRepo;

  Future<void> fetchRoutes() async =>
      emit(WalkRoutesStateLoaded([..._walkRoutesRepo.getRoutes()]));

  void addRoute(WalkRoute route) {
    _walkRoutesRepo.addRoute(route);
    emit(WalkRoutesStateLoaded([...state.routes, route]));
  }

  void removeRoute(WalkRoute route) {
    _walkRoutesRepo.removeRouteById(route.id);
    emit(WalkRoutesStateLoaded([...state.routes]..remove(route)));
  }
}

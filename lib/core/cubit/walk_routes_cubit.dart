import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';

part 'walk_routes_state.dart';

class WalkRoutesCubit extends Cubit<WalkRoutesState> {
  WalkRoutesCubit(this._walkRoutesRepo) : super(WalkRoutesStateUninitialized());

  final WalkRoutesRepo _walkRoutesRepo;

  Future<void> retrieveRoutesForWorkout(WalkWorkout workout) async {
    final route = await _walkRoutesRepo.retrieveRouteForWorkout(workout);
    final routes = [...state.routes, route];
    emit(WalkRoutesStateLoaded(routes));
  }
}

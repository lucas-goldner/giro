import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

part 'healthkit_state.dart';

class HealthkitCubit extends Cubit<HealthKitState> {
  HealthkitCubit(this._healthkitRepo)
      : super(const HealthKitStateUninitialized());
  final HealthkitRepo _healthkitRepo;

  bool get isAuthorized => state.authorized;

  Future<void> authorize() async {
    final authorized = await _healthkitRepo.requestAuthorization();
    emit(
      authorized
          ? HealthKitStateAuthorized(workouts: state.workouts)
          : const HealthKitStateUnauthorized(),
    );
  }

  Future<void> retrieveWorkoutsWithRoutes({int limit = 25}) async {
    if (state is! HealthKitStateAuthorized) {
      return;
    }
    emit(const HealthKitStateLoadingWorkout());
    final workouts =
        await _healthkitRepo.retrieveWorkoutsWithRoutes(limit: limit);
    final workoutsOrdered = workouts
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    emit(
      HealthKitStateAuthorized(
        workouts: [...state.workouts, ...workoutsOrdered],
      ),
    );
  }
}

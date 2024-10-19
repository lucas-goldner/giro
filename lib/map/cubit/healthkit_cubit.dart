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

  Future<void> retrieveLastWalkingWorkouts({int limit = 10}) async {
    final workouts =
        await _healthkitRepo.retrieveLastWalkingWorkouts(limit: limit);

    if (state is! HealthKitStateAuthorized) {
      await authorize();
      emit(HealthKitStateAuthorized(workouts: workouts));
    } else {
      emit(
        HealthKitStateAuthorized(workouts: [...state.workouts, ...workouts]),
      );
    }
  }
}

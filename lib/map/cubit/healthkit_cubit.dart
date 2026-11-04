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

  /// Walks through the whole Health history in pages of [pageSize], calling
  /// [onPage] for each page so callers can save as they go.
  Future<void> retrieveAll({
    int pageSize = 25,
    void Function(List<WalkWorkout> page)? onPage,
  }) async {
    if (state is! HealthKitStateAuthorized) {
      return;
    }
    final all = <WalkWorkout>[];
    DateTime? before;
    emit(const HealthKitStateImporting(workouts: [], fetched: 0));
    while (true) {
      final page = await _healthkitRepo.retrieveWorkoutsWithRoutes(
        limit: pageSize,
        before: before,
      );
      if (page.isEmpty) {
        break;
      }
      final sorted = [...page]..sort((a, b) => b.endDate.compareTo(a.endDate));
      all.addAll(sorted);
      onPage?.call(sorted);
      emit(
        HealthKitStateImporting(workouts: List.of(all), fetched: all.length),
      );
      if (page.length < pageSize) {
        break;
      }
      before = sorted.last.endDate;
    }
    emit(HealthKitStateAuthorized(workouts: all));
  }

  Future<void> retrieveWorkoutsWithRoutes({int limit = 25}) async {
    if (state is! HealthKitStateAuthorized) {
      return;
    }
    emit(const HealthKitStateLoadingWorkout());
    final workouts = await _healthkitRepo.retrieveWorkoutsWithRoutes(
      limit: limit,
    );
    final workoutsOrdered = workouts
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    emit(
      HealthKitStateAuthorized(
        workouts: [...state.workouts, ...workoutsOrdered],
      ),
    );
  }
}

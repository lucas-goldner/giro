import 'package:giro/core/model/walk_workout.dart';

abstract class HealthkitRepo {
  Future<bool> requestAuthorization();

  /// Walking workouts, newest first. [limit] 0 means no limit; with [before]
  /// only workouts that ended before that moment, which is how
  /// `HealthkitCubit.retrieveAll` pages through the whole history.
  Future<List<WalkWorkout>> retrieveWorkoutsWithRoutes({
    int limit = 10,
    DateTime? before,
  });
}

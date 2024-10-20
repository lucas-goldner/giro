import 'package:giro/core/model/walk_workout.dart';

abstract class HealthkitRepo {
  Future<bool> requestAuthorization();
  Future<List<WalkWorkout>> retrieveWorkoutsWithRoutes({int limit = 10});
}

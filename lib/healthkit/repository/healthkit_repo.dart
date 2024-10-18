import 'package:giro/core/model/walking_workout.dart';
import 'package:giro/core/model/workout_route.dart';

abstract class HealthkitRepo {
  Future<bool> requestAuthorization();
  Future<List<WalkingWorkout>> retrieveLastWalkingWorkouts({int limit = 10});
  Future<WorkoutRoute?> retrieveRouteForWorkout();
}

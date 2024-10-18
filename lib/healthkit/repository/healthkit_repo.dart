abstract class HealthkitRepo {
  Future<bool> requestAuthorization();
  Future<void> retrieveLastWalkingWorkout({int limit = 10});
}

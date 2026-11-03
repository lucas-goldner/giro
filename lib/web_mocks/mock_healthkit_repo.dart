import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

/// Stands in for the HealthKit method channel, which only exists in the iOS
/// Runner. Answers with canned workouts after a short, realistic delay.
class MockHealthkitRepo implements HealthkitRepo {
  MockHealthkitRepo({
    required this.workouts,
    this.authorized = true,
    this.latency = const Duration(milliseconds: 400),
  });

  final List<WalkWorkout> workouts;
  final bool authorized;
  final Duration latency;

  @override
  Future<bool> requestAuthorization() =>
      Future<bool>.delayed(latency, () => authorized);

  @override
  Future<List<WalkWorkout>> retrieveWorkoutsWithRoutes({
    int limit = 10,
    DateTime? before,
  }) => Future<List<WalkWorkout>>.delayed(latency, () {
    final sorted = [...workouts]
      ..sort((a, b) => b.endDate.compareTo(a.endDate));
    final page = before == null
        ? sorted
        : sorted.where((w) => w.endDate.isBefore(before)).toList();
    return limit <= 0 ? page : page.take(limit).toList();
  });
}

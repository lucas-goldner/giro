import 'package:giro/healthkit/repository/healthkit_repo.dart';

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  @override
  Future<bool> requestAuthorization() {
    throw UnimplementedError();
  }

  @override
  Future<void> retrieveLastWalkingWorkout({int limit = 10}) {
    throw UnimplementedError();
  }
}

import 'package:flutter/services.dart';
import 'package:giro/core/model/walking_workout.dart';
import 'package:giro/core/model/workout_route.dart';
import 'package:giro/healthkit/repository/healthkit_repo.dart';

enum MethodChannelHealthkitMethods {
  requestAuthorization,
  retrieveLastWalkingWorkout,
  retrieveRouteForWorkout
}

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');

  @override
  Future<bool> requestAuthorization() async => await _channel.invokeMethod(
        MethodChannelHealthkitMethods.requestAuthorization.name,
      ) as bool;

  @override
  Future<List<WalkingWorkout>> retrieveLastWalkingWorkouts({int limit = 10}) {
    _channel.invokeMethod(
      MethodChannelHealthkitMethods.retrieveLastWalkingWorkout.name,
    ) as List<WalkingWorkout>;

    return Future.value([]);
  }

  @override
  Future<WorkoutRoute> retrieveRouteForWorkout() {
    _channel.invokeMethod(
      MethodChannelHealthkitMethods.retrieveLastWalkingWorkout.name,
    ) as bool;

    return Future.value();
  }
}

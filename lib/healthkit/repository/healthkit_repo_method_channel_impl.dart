import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:giro/core/model/walking_workout.dart';
import 'package:giro/core/model/workout_route.dart';
import 'package:giro/healthkit/repository/healthkit_repo.dart';

enum MethodChannelHealthkitMethods {
  requestAuthorization,
  retrieveLastWalkingWorkouts,
  retrieveRouteForWorkout
}

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  static const MethodChannel _channel =
      MethodChannel('com.lucas-goldner.giro/healthkit');

  @override
  Future<bool> requestAuthorization() async => await _channel.invokeMethod(
        MethodChannelHealthkitMethods.requestAuthorization.name,
      ) as bool;

  @override
  Future<List<WalkingWorkout>> retrieveLastWalkingWorkouts({
    int limit = 10,
  }) async {
    final pastWorkoutsAsJSONStrings = await _channel.invokeMethod(
      MethodChannelHealthkitMethods.retrieveLastWalkingWorkouts.name,
      limit,
    ) as List<dynamic>;

    final pastWorkoutsAsJSON = pastWorkoutsAsJSONStrings
        .map(
          (workout) => json.decode(workout as String) as Map<String, dynamic>,
        )
        .toList();

    return pastWorkoutsAsJSON.map(WalkingWorkout.fromJson).toList();
  }

  @override
  Future<WorkoutRoute> retrieveRouteForWorkout() {
    _channel.invokeMethod(
      MethodChannelHealthkitMethods.retrieveRouteForWorkout.name,
    ) as bool;

    return Future.value();
  }
}

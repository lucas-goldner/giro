import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

enum MethodChannelHealthkitMethods {
  requestAuthorization,
  retrieveLastWalkingWorkouts,
}

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  static const MethodChannel _channel =
      MethodChannel('com.lucas-goldner.giro/healthkit');

  @override
  Future<bool> requestAuthorization() async => await _channel.invokeMethod(
        MethodChannelHealthkitMethods.requestAuthorization.name,
      ) as bool;

  @override
  Future<List<WalkWorkout>> retrieveLastWalkingWorkouts({
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

    return pastWorkoutsAsJSON.map(WalkWorkout.fromJson).toList();
  }
}

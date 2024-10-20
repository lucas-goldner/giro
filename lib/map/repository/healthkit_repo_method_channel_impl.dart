import 'package:flutter/services.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

enum MethodChannelHealthkitMethods {
  requestAuthorization,
  retrieveWorkoutsWithRoutes,
}

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  static const MethodChannel _channel =
      MethodChannel('com.lucas-goldner.giro/healthkit');

  @override
  Future<bool> requestAuthorization() async => await _channel.invokeMethod(
        MethodChannelHealthkitMethods.requestAuthorization.name,
      ) as bool;

  @override
  Future<List<WalkWorkout>> retrieveWorkoutsWithRoutes({
    int limit = 10,
  }) async {
    final pastWorkoutsAsJSONStrings = await _channel.invokeMethod(
      MethodChannelHealthkitMethods.retrieveWorkoutsWithRoutes.name,
      limit,
    ) as List<dynamic>;

    final pastWorkouts = pastWorkoutsAsJSONStrings
        .map((workout) => Map<String, dynamic>.from(workout as Map))
        .toList();

    return pastWorkouts.map(WalkWorkout.fromJson).toList();
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';

enum MethodChannelWalkRoutesMethods {
  retrieveRouteForWorkout,
}

class WalkRoutesRepoImpl extends WalkRoutesRepo {
  static const MethodChannel _channel =
      MethodChannel('com.lucas-goldner.giro/workout_routes');

  @override
  Future<WalkRoute> retrieveRouteForWorkout(WalkWorkout workout) async {
    final routeJSONString = await _channel.invokeMethod(
      MethodChannelWalkRoutesMethods.retrieveRouteForWorkout.name,
      workout.toJson().toString(),
    ) as String;

    final routeJSON = json.decode(routeJSONString) as Map<String, dynamic>;

    return WalkRoute.fromJson(routeJSON);
  }
}

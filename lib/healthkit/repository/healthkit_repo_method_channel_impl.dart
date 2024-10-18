import 'package:flutter/services.dart';
import 'package:giro/healthkit/repository/healthkit_repo.dart';

enum MethodChannelHealthkitMethods {
  requestAuthorization,
  retrieveLastWalkingWorkout,
}

class HealthkitRepoMethodChannelImpl implements HealthkitRepo {
  static const MethodChannel _channel = MethodChannel('healthkit_channel');

  @override
  Future<bool> requestAuthorization() async => await _channel.invokeMethod(
        MethodChannelHealthkitMethods.requestAuthorization.name,
      ) as bool;

  @override
  Future<void> retrieveLastWalkingWorkout({int limit = 10}) {
    return Future.value();
  }
}

import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/model/walk_workout.dart';

abstract class WalkRoutesRepo {
  Future<WalkRoute> retrieveRouteForWorkout(WalkWorkout workout);
}

import 'dart:math';

class WorkoutRoute {
  WorkoutRoute({
    required this.coordinates,
    required this.date,
  });

  final List<Point> coordinates;
  final DateTime date;
}

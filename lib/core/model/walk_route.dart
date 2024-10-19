import 'dart:math';

class WalkRoute {
  WalkRoute({
    required this.coordinates,
    required this.startDate,
    required this.endDate,
  });

  factory WalkRoute.fromJson(Map<String, dynamic> routeJSON) {
    final coordinates = (routeJSON['coordinates'] as List<dynamic>)
        .map(
          (coordinate) => Point(
            (coordinate['latitude'] as num).toDouble(),
            (coordinate['longitude'] as num).toDouble(),
          ),
        )
        .toList();

    return WalkRoute(
      coordinates: coordinates,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        ((routeJSON['startDate'] as num) * 1000).round(),
        isUtc: true,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        ((routeJSON['endDate'] as num) * 1000).round(),
        isUtc: true,
      ),
    );
  }

  final List<Point> coordinates;
  final DateTime startDate;
  final DateTime endDate;
}

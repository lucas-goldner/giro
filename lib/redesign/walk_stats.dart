import 'dart:math' as math;

import 'package:giro/core/model/walk_route.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Derived numbers the redesigns show (the model only stores coordinates).
extension WalkRouteStats on WalkRoute {
  double get distanceMeters {
    var total = 0.0;
    for (var i = 1; i < coordinates.length; i++) {
      total += _haversine(coordinates[i - 1], coordinates[i]);
    }
    return total;
  }

  String get distanceLabel => formatDistance(distanceMeters);

  String get durationLabel => formatDuration(duration);
}

extension WalkRoutesStats on Iterable<WalkRoute> {
  double get totalDistanceMeters =>
      fold(0, (sum, route) => sum + route.distanceMeters);

  Duration get totalDuration =>
      fold(Duration.zero, (sum, route) => sum + route.duration);
}

String formatDistance(double meters) => meters >= 1000
    ? '${(meters / 1000).toStringAsFixed(1)} km'
    : '${meters.round()} m';

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return hours > 0
      ? '${hours}h ${minutes.toString().padLeft(2, '0')}m'
      : '${minutes}m';
}

double _haversine(LatLng a, LatLng b) {
  const earthRadius = 6371000.0;
  final dLat = _radians(b.latitude - a.latitude);
  final dLng = _radians(b.longitude - a.longitude);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_radians(a.latitude)) *
          math.cos(_radians(b.latitude)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadius * math.asin(math.sqrt(h));
}

double _radians(double degrees) => degrees * math.pi / 180;

import 'dart:math' as math;

import 'package:giro/core/model/walk_route.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "New ground" and ranks: the game layer on top of the fog of war.
abstract final class SonicStats {
  /// A point counts as already explored if it is within this distance of a
  /// coordinate of an earlier walk.
  static const double exploredRadiusMeters = 60;

  /// Share of [route]'s points that were not within [exploredRadiusMeters]
  /// of any walk in [earlier] (0..1). A first walk is all new ground.
  static double newGroundShare(WalkRoute route, Iterable<WalkRoute> earlier) {
    if (route.coordinates.isEmpty) {
      return 0;
    }
    final known = [for (final other in earlier) ...other.coordinates];
    if (known.isEmpty) {
      return 1;
    }
    var fresh = 0;
    for (final point in route.coordinates) {
      if (!_nearAny(point, known)) {
        fresh++;
      }
    }
    return fresh / route.coordinates.length;
  }

  /// Metres of [route] that were new ground, approximated from its share.
  static double newGroundMeters(WalkRoute route, Iterable<WalkRoute> earlier) =>
      route.distanceMeters * newGroundShare(route, earlier);

  /// Walks recorded before [route], the ones that could have explored its
  /// streets first.
  static Iterable<WalkRoute> earlierThan(
    WalkRoute route,
    Iterable<WalkRoute> all,
  ) => all.where(
    (other) =>
        other.id != route.id && other.startDate.isBefore(route.startDate),
  );

  /// Stage rank from the new-ground share.
  static String rankFor(double newGroundShare) => switch (newGroundShare) {
    >= 0.8 => 'S',
    >= 0.5 => 'A',
    >= 0.25 => 'B',
    _ => 'C',
  };

  /// Weekly rank from total distance.
  static String weekRank(double totalMeters) => switch (totalMeters) {
    >= 10000 => 'S',
    >= 5000 => 'A',
    >= 2000 => 'B',
    _ => 'C',
  };

  static bool _nearAny(LatLng point, List<LatLng> known) {
    for (final other in known) {
      if (_approxMeters(point, other) <= exploredRadiusMeters) {
        return true;
      }
    }
    return false;
  }

  /// Fast equirectangular distance, accurate enough at street scale.
  static double _approxMeters(LatLng a, LatLng b) {
    const metersPerDegree = 111320.0;
    final dLat = (a.latitude - b.latitude) * metersPerDegree;
    final dLng =
        (a.longitude - b.longitude) *
        metersPerDegree *
        math.cos(a.latitude * math.pi / 180);
    return math.sqrt(dLat * dLat + dLng * dLng);
  }
}

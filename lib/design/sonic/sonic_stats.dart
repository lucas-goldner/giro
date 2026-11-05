import 'dart:math' as math;

import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/design/shared/walk_stats.dart';

/// "New ground" and ranks: the game layer on top of the fog of war.
abstract final class SonicStats {
  /// A point counts as already explored if it is within this distance of a
  /// coordinate of an earlier walk.
  static const double exploredRadiusMeters = 60;

  /// Share of [route]'s points that were not within [exploredRadiusMeters]
  /// of any walk in [earlier] (0..1). A first walk is all new ground.
  ///
  /// For many walks at once use [ExploredIndex], which answers the same
  /// question for every walk from one spatial index instead of comparing
  /// every point with every other point.
  static double newGroundShare(WalkRoute route, Iterable<WalkRoute> earlier) {
    if (route.coordinates.isEmpty) {
      return 0;
    }
    final index = ExploredIndex(earlier);
    if (index.isEmpty) {
      return 1;
    }
    return index.newGroundShare(route);
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
}

/// Every coordinate of a set of walks, bucketed into a grid of
/// [SonicStats.exploredRadiusMeters] cells, so "is this point near any
/// earlier walk" is a lookup of nine cells instead of a scan of thousands
/// of points.
///
/// Build it once per list of walks ([ExploredIndex.cached] does that) and
/// ask it for every stage's rank: the stage select scrolls through 70
/// walks without recomputing anything.
class ExploredIndex {
  ExploredIndex(Iterable<WalkRoute> routes) {
    for (final route in routes) {
      final startedAt = route.startDate.millisecondsSinceEpoch;
      for (final point in route.coordinates) {
        _cells
            .putIfAbsent(_cellKey(point), () => <_Sample>[])
            .add(_Sample(point, route.id, startedAt));
      }
    }
  }

  /// The index for [routes], reused while the same walks are shown.
  factory ExploredIndex.cached(List<WalkRoute> routes) {
    final key = Object.hashAll([for (final route in routes) route.id]);
    final cached = _cachedIndex;
    if (_cachedKey == key && cached != null) {
      return cached;
    }
    final index = ExploredIndex(routes);
    _cachedIndex = index;
    _cachedKey = key;
    return index;
  }

  static ExploredIndex? _cachedIndex;
  static int? _cachedKey;

  static const double _metersPerDegreeLat = 111320;

  final _cells = <int, List<_Sample>>{};
  final _shares = <String, double>{};

  bool get isEmpty => _cells.isEmpty;

  /// Share of [route]'s points that no walk started before it had explored.
  double newGroundShare(WalkRoute route) {
    final cached = _shares[route.id];
    if (cached != null) {
      return cached;
    }
    if (route.coordinates.isEmpty) {
      return 0;
    }
    final startedAt = route.startDate.millisecondsSinceEpoch;
    var fresh = 0;
    for (final point in route.coordinates) {
      if (!_nearEarlier(point, route.id, startedAt)) {
        fresh++;
      }
    }
    return _shares[route.id] = fresh / route.coordinates.length;
  }

  String rankOf(WalkRoute route) => SonicStats.rankFor(newGroundShare(route));

  bool _nearEarlier(LatLng point, String routeId, int startedAt) {
    final cellLat = _cellLat(point.latitude);
    final cellLng = _cellLng(point.longitude, point.latitude);
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final samples = _cells[_key(cellLat + dy, cellLng + dx)];
        if (samples == null) {
          continue;
        }
        for (final sample in samples) {
          if (sample.routeId == routeId || sample.startedAt >= startedAt) {
            continue;
          }
          if (_approxMeters(point, sample.point) <=
              SonicStats.exploredRadiusMeters) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int _cellLat(double latitude) =>
      (latitude * _metersPerDegreeLat / SonicStats.exploredRadiusMeters)
          .floor();

  int _cellLng(double longitude, double latitude) =>
      (longitude *
              _metersPerDegreeLat *
              math.cos(latitude * math.pi / 180) /
              SonicStats.exploredRadiusMeters)
          .floor();

  int _cellKey(LatLng point) =>
      _key(_cellLat(point.latitude), _cellLng(point.longitude, point.latitude));

  static int _key(int cellLat, int cellLng) => cellLat * 4000037 + cellLng;

  /// Fast equirectangular distance, accurate enough at street scale.
  static double _approxMeters(LatLng a, LatLng b) {
    final dLat = (a.latitude - b.latitude) * _metersPerDegreeLat;
    final dLng =
        (a.longitude - b.longitude) *
        _metersPerDegreeLat *
        math.cos(a.latitude * math.pi / 180);
    return math.sqrt(dLat * dLat + dLng * dLng);
  }
}

class _Sample {
  const _Sample(this.point, this.routeId, this.startedAt);

  final LatLng point;
  final String routeId;
  final int startedAt;
}

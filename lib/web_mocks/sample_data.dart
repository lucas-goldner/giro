import 'package:giro/core/model/poi.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Deterministic sample content (walks around Tokyo) for the web preview and
/// widget tests.
abstract final class SampleData {
  static const tokyoStation = LatLng(35.681236, 139.767125);
  static const shibuya = LatLng(35.659025, 139.700464);
  static const meijiJingu = LatLng(35.676398, 139.699326);
  static const tokyoTower = LatLng(35.658581, 139.745433);

  static final List<WalkRoute> walkRoutes = [
    WalkRoute(
      coordinates: walkAround(
        start: const LatLng(35.6838, 139.7596),
        legs: const [
          (0.0022, 0),
          (0, 0.0035),
          (0.0018, 0.0004),
          (0, 0.0030),
          (-0.0040, 0.0005),
          (0, -0.0026),
          (-0.0015, 0),
        ],
      ),
      startDate: DateTime.utc(2026, 10, 28, 7, 30),
      endDate: DateTime.utc(2026, 10, 28, 8, 25),
    ),
    WalkRoute(
      coordinates: walkAround(
        start: shibuya,
        legs: const [
          (0.0016, 0.0004),
          (0.0014, -0.0022),
          (0.0030, 0),
          (0.0010, 0.0018),
          (-0.0010, 0.0024),
        ],
      ),
      startDate: DateTime.utc(2026, 10, 26, 17, 5),
      endDate: DateTime.utc(2026, 10, 26, 17, 48),
    ),
    WalkRoute(
      coordinates: walkAround(
        start: const LatLng(35.6553, 139.7429),
        legs: const [
          (0.0021, 0.0006),
          (0.0012, 0.0024),
          (-0.0009, 0.0030),
          (-0.0026, 0.0008),
        ],
      ),
      startDate: DateTime.utc(2026, 10, 22, 12, 10),
      endDate: DateTime.utc(2026, 10, 22, 12, 41),
    ),
  ];

  static final List<POI> pois = [
    POI(
      name: 'Imperial Palace East Garden',
      coordinates: const LatLng(35.6864, 139.7572),
      createdAt: DateTime.utc(2026, 10, 28, 8),
    ),
    POI(
      name: 'Shibuya Crossing',
      coordinates: shibuya,
      createdAt: DateTime.utc(2026, 10, 26, 17, 20),
    ),
    POI(
      name: 'Meiji Jingu',
      coordinates: meijiJingu,
      createdAt: DateTime.utc(2026, 10, 26, 17, 40),
    ),
    POI(
      name: 'Tokyo Tower',
      coordinates: tokyoTower,
      createdAt: DateTime.utc(2026, 10, 22, 12, 30),
    ),
  ];

  /// What the HealthKit mock reports: the first two overlap with
  /// [walkRoutes] so the importer shows them as "Imported already".
  static final List<WalkWorkout> workouts = [
    for (final route in walkRoutes.take(2)) _workoutFromRoute(route),
    _workoutFromRoute(
      WalkRoute(
        coordinates: walkAround(
          start: const LatLng(35.7148, 139.7967),
          legs: const [
            (0.0014, 0.0020),
            (0.0022, -0.0006),
            (0.0006, 0.0028),
            (-0.0030, 0.0010),
          ],
        ),
        startDate: DateTime.utc(2026, 10, 30, 9, 2),
        endDate: DateTime.utc(2026, 10, 30, 9, 39),
      ),
    ),
    _workoutFromRoute(
      WalkRoute(
        coordinates: walkAround(
          start: const LatLng(35.6286, 139.7390),
          legs: const [
            (0.0020, 0.0010),
            (0.0004, 0.0032),
            (-0.0024, 0.0008),
          ],
        ),
        startDate: DateTime.utc(2026, 10, 29, 18, 45),
        endDate: DateTime.utc(2026, 10, 29, 19, 12),
      ),
    ),
  ];

  /// The loop the geolocation mock walks along while recording. One sample
  /// is taken every 5 seconds, so the steps are long enough (roughly 50 m)
  /// for a short recording to be visible at zoom 16.
  static final List<LatLng> recordingPath = walkAround(
    start: tokyoStation,
    legs: const [
      (0.0010, 0),
      (0, 0.0012),
      (0.0010, 0.0003),
      (0, 0.0014),
      (-0.0020, 0.0002),
      (0, -0.0031),
    ],
    pointsPerLeg: 2,
  );

  /// Builds a street-like path: every leg is a straight segment described by
  /// a (latitude, longitude) delta, subdivided into [pointsPerLeg] samples.
  static List<LatLng> walkAround({
    required LatLng start,
    required List<(double, double)> legs,
    int pointsPerLeg = 6,
  }) {
    final points = <LatLng>[start];
    var current = start;
    for (final (deltaLat, deltaLng) in legs) {
      for (var i = 1; i <= pointsPerLeg; i++) {
        final t = i / pointsPerLeg;
        points.add(
          LatLng(
            current.latitude + deltaLat * t,
            current.longitude + deltaLng * t,
          ),
        );
      }
      current = LatLng(
        current.latitude + deltaLat,
        current.longitude + deltaLng,
      );
    }
    return points;
  }

  static WalkWorkout _workoutFromRoute(WalkRoute route) => WalkWorkout(
        activityType: 52, // HKWorkoutActivityTypeWalking
        startDate: route.startDate,
        endDate: route.endDate,
        duration: route.duration.inSeconds.toDouble(),
        totalDistance: route.coordinates.length * 42.0,
        totalEnergyBurned: route.duration.inMinutes * 4.2,
        routes: route.coordinates,
      );
}

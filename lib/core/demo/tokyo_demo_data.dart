import 'dart:math' as math;

import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/core/model/walk_route.dart';

/// Synthetic walks and spots across all 23 wards of Tokyo, for seeing what
/// the app looks like once most of the city is explored.
///
/// Everything is generated from a fixed seed, so "remove demo data" can
/// regenerate the same walks and delete them by id without tagging real
/// data. Walks are Manhattan-style random strolls (streets run roughly
/// north-south and east-west) with a little GPS jitter, 2 to 9 km each,
/// spread over the last two years.
abstract final class TokyoDemoData {
  static const seed = 20261105;

  /// Walk dates count back from here, so ids never change between launches
  /// (a walk's id includes its start time).
  static final anchor = DateTime(2026, 11, 4, 18);

  /// Ward centres with a rough radius in km, so walks cluster where the
  /// ward actually is.
  static const wards = <_Ward>[
    _Ward('Chiyoda', 35.694, 139.753, 2.2),
    _Ward('Chuo', 35.670, 139.772, 2.2),
    _Ward('Minato', 35.658, 139.751, 2.6),
    _Ward('Shinjuku', 35.694, 139.703, 2.6),
    _Ward('Bunkyo', 35.708, 139.752, 2),
    _Ward('Taito', 35.712, 139.780, 1.9),
    _Ward('Sumida', 35.710, 139.801, 2.1),
    _Ward('Koto', 35.673, 139.817, 3.2),
    _Ward('Shinagawa', 35.609, 139.730, 2.8),
    _Ward('Meguro', 35.641, 139.698, 2.3),
    _Ward('Ota', 35.561, 139.716, 4),
    _Ward('Setagaya', 35.646, 139.653, 4.2),
    _Ward('Shibuya', 35.664, 139.698, 2.2),
    _Ward('Nakano', 35.707, 139.664, 2.2),
    _Ward('Suginami', 35.700, 139.636, 3.2),
    _Ward('Toshima', 35.726, 139.716, 2),
    _Ward('Kita', 35.753, 139.734, 2.4),
    _Ward('Arakawa', 35.736, 139.783, 1.8),
    _Ward('Itabashi', 35.751, 139.709, 3),
    _Ward('Nerima', 35.736, 139.652, 3.6),
    _Ward('Adachi', 35.775, 139.805, 3.8),
    _Ward('Katsushika', 35.744, 139.847, 3.2),
    _Ward('Edogawa', 35.707, 139.868, 3.6),
  ];

  static const _landmarks = <(String, double, double)>[
    ('Tokyo Tower', 35.6586, 139.7454),
    ('Tokyo Skytree', 35.7101, 139.8107),
    ('Sensō-ji', 35.7148, 139.7967),
    ('Meiji Jingū', 35.6764, 139.6993),
    ('Shibuya Crossing', 35.6595, 139.7005),
    ('Shinjuku Gyoen', 35.6852, 139.7100),
    ('Ueno Park', 35.7153, 139.7739),
    ('Akihabara Electric Town', 35.6984, 139.7731),
    ('Roppongi Hills', 35.6605, 139.7292),
    ('Tsukiji Outer Market', 35.6654, 139.7707),
    ('Tokyo Station', 35.6812, 139.7671),
    ('Imperial Palace East Garden', 35.6868, 139.7566),
    ('Tokyo Dome', 35.7056, 139.7519),
    ('Yoyogi Park', 35.6717, 139.6949),
    ('Takeshita Street', 35.6716, 139.7030),
    ('Ginza Wako', 35.6717, 139.7649),
    ('Sunshine City', 35.7295, 139.7195),
    ('Nakameguro Canal', 35.6440, 139.6990),
    ('Shimokitazawa', 35.6613, 139.6681),
    ('Ryōgoku Kokugikan', 35.6967, 139.7933),
    ('Zōjō-ji', 35.6574, 139.7484),
    ('Hamarikyu Gardens', 35.6598, 139.7634),
    ('Toyosu Market', 35.6457, 139.7853),
    ('Kiyosumi Garden', 35.6803, 139.7975),
    ('Rikugien', 35.7331, 139.7460),
    ('Koishikawa Kōrakuen', 35.7054, 139.7495),
    ('Jiyūgaoka', 35.6076, 139.6690),
    ('Daikanyama T-Site', 35.6490, 139.6997),
    ('Ebisu Garden Place', 35.6426, 139.7132),
    ('Omotesandō', 35.6652, 139.7124),
    ('Yanaka Ginza', 35.7273, 139.7656),
    ('Nezu Shrine', 35.7202, 139.7612),
    ('Kanda Myōjin', 35.7020, 139.7679),
    ('Gotokuji Temple', 35.6487, 139.6513),
    ('Kōenji', 35.7053, 139.6497),
    ('Nakano Broadway', 35.7083, 139.6655),
    ('Kameido Tenjin', 35.7024, 139.8275),
    ('Kasai Rinkai Park', 35.6423, 139.8622),
    ('Shibamata Taishakuten', 35.7599, 139.8750),
    ('Ōji Asukayama Park', 35.7514, 139.7363),
    ('Shinagawa Aquarium', 35.5900, 139.7392),
    ('Haneda Observation Deck', 35.5494, 139.7798),
    ('Todoroki Valley', 35.6064, 139.6464),
    ('Hikarigaoka Park', 35.7627, 139.6295),
    ('Senzoku Pond', 35.6013, 139.6935),
  ];

  static const _earthMetersPerDegree = 111320.0;

  /// All demo walks: [walksPerWard] per ward, deterministic.
  static List<WalkRoute> walks({int walksPerWard = 14}) {
    final random = math.Random(seed);
    final routes = <WalkRoute>[];
    var index = 0;
    for (final ward in wards) {
      for (var i = 0; i < walksPerWard; i++) {
        final coordinates = _stroll(random, ward);
        final meters = coordinates.length * _stepMeters;
        final start = DateTime(
          anchor.year,
          anchor.month,
          anchor.day,
          7 + random.nextInt(12),
          random.nextInt(60),
        ).subtract(Duration(days: (index * 2.3).round() % 730));
        final duration = Duration(seconds: (meters / 1.3).round());
        routes.add(
          WalkRoute(
            coordinates: coordinates,
            startDate: start,
            endDate: start.add(duration),
          ),
        );
        index++;
      }
    }
    return routes;
  }

  /// Famous places as spots.
  static List<POI> spots() => [
    for (final (name, lat, lng) in _landmarks)
      POI(
        name: name,
        coordinates: LatLng(lat, lng),
        createdAt: DateTime.utc(2026),
      ),
  ];

  static const _stepMeters = 20.0;

  /// A Manhattan random walk: straight runs of 80 to 400 m, right-angle
  /// turns, a little jitter, kept inside the ward.
  static List<LatLng> _stroll(math.Random random, _Ward ward) {
    final lengthMeters = 2000 + random.nextInt(7000);
    final steps = lengthMeters ~/ _stepMeters;
    final cosLat = math.cos(ward.latitude * math.pi / 180);
    // Uniform start inside the ward disc.
    final r = ward.radiusKm * 1000 * math.sqrt(random.nextDouble());
    final theta = random.nextDouble() * 2 * math.pi;
    var north = r * math.sin(theta);
    var east = r * math.cos(theta);
    // Streets in each ward are rotated a little from true north.
    final grid = (random.nextDouble() - 0.5) * 0.5;
    var heading = grid + random.nextInt(4) * math.pi / 2;
    var runLeft = 0;
    final points = <LatLng>[];
    for (var step = 0; step < steps; step++) {
      if (runLeft <= 0) {
        heading = grid + random.nextInt(4) * math.pi / 2;
        runLeft = 4 + random.nextInt(16);
      }
      final limit = ward.radiusKm * 1000 * 1.15;
      if (north * north + east * east > limit * limit) {
        heading = math.atan2(-north, -east) + (random.nextDouble() - 0.5);
        runLeft = 10;
      }
      east += math.cos(heading) * _stepMeters + (random.nextDouble() - 0.5) * 3;
      north +=
          math.sin(heading) * _stepMeters + (random.nextDouble() - 0.5) * 3;
      runLeft--;
      points.add(
        LatLng(
          ward.latitude + north / _earthMetersPerDegree,
          ward.longitude + east / (_earthMetersPerDegree * cosLat),
        ),
      );
    }
    return points;
  }
}

class _Ward {
  const _Ward(this.name, this.latitude, this.longitude, this.radiusKm);

  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
}

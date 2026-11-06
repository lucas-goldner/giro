import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:giro/core/map/scenery/landmarks.dart';
import 'package:giro/core/model/geo.dart';

/// A tappable point drawn on the map (a saved spot).
@immutable
class MapMarker {
  const MapMarker({
    required this.id,
    required this.position,
    this.onTap,
    this.landmark,
  });

  final String id;
  final LatLng position;
  final VoidCallback? onTap;

  /// The 3D model drawn at this spot in the toy city (iOS); see
  /// `LandmarkModel`. Null draws nothing in 3D.
  final LandmarkModel? landmark;

  @override
  bool operator ==(Object other) =>
      other is MapMarker &&
      other.id == id &&
      other.position == position &&
      other.landmark == landmark;

  @override
  int get hashCode => Object.hash(id, position, landmark);
}

/// A line drawn on the map (a walk).
@immutable
class MapPolyline {
  const MapPolyline({
    required this.id,
    required this.points,
    this.color = const Color(0xFF1B5BFF),
    this.width = 4,
  });

  final String id;
  final List<LatLng> points;
  final Color color;

  /// Logical pixels.
  final double width;

  @override
  bool operator ==(Object other) =>
      other is MapPolyline &&
      other.id == id &&
      other.color == color &&
      other.width == width &&
      listEquals(other.points, points);

  @override
  int get hashCode => Object.hash(id, color, width, points.length);
}

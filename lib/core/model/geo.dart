import 'package:flutter/foundation.dart';

/// A geographic coordinate in degrees.
///
/// Giro's own type so that models, cubits and widgets do not depend on any
/// map SDK. Each map backend converts to and from its own coordinate class.
@immutable
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Where a map looks: centre, zoom and optional rotation/tilt.
@immutable
class CameraPosition {
  const CameraPosition({
    required this.target,
    this.zoom = 14,
    this.bearing = 0,
    this.tilt = 0,
  });

  final LatLng target;
  final double zoom;
  final double bearing;
  final double tilt;

  @override
  bool operator ==(Object other) =>
      other is CameraPosition &&
      other.target == target &&
      other.zoom == zoom &&
      other.bearing == bearing &&
      other.tilt == tilt;

  @override
  int get hashCode => Object.hash(target, zoom, bearing, tilt);

  @override
  String toString() =>
      'CameraPosition($target, zoom: $zoom, bearing: $bearing, tilt: $tilt)';
}

/// An axis-aligned area on the map.
@immutable
class LatLngBounds {
  const LatLngBounds({required this.southWest, required this.northEast});

  final LatLng southWest;
  final LatLng northEast;

  double get north => northEast.latitude;
  double get south => southWest.latitude;
  double get east => northEast.longitude;
  double get west => southWest.longitude;

  LatLng get center => LatLng((north + south) / 2, (east + west) / 2);

  @override
  bool operator ==(Object other) =>
      other is LatLngBounds &&
      other.southWest == southWest &&
      other.northEast == northEast;

  @override
  int get hashCode => Object.hash(southWest, northEast);

  @override
  String toString() => 'LatLngBounds($southWest, $northEast)';
}

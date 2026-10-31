import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Drop-in replacement for the geolocator plugin.
///
/// Install it with `GeolocatorPlatform.instance = MockGeolocatorPlatform(...)`
/// before the app starts. Permissions are always granted and every position
/// request advances one step along [path], so "Record walk" produces a route
/// without a real GPS.
class MockGeolocatorPlatform extends GeolocatorPlatform {
  MockGeolocatorPlatform({required this.path})
      : assert(path.isNotEmpty, 'path must contain at least one point');

  final List<LatLng> path;
  int _index = 0;

  Position _positionAt(LatLng latLng) => Position(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        timestamp: DateTime.now(),
        accuracy: 5,
        altitude: 12,
        altitudeAccuracy: 3,
        heading: 0,
        headingAccuracy: 0,
        speed: 1.3,
        speedAccuracy: 0.5,
        isMocked: true,
      );

  Position _next() {
    final position = _positionAt(path[_index]);
    _index = (_index + 1) % path.length;
    return position;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async =>
      _positionAt(path[_index]);

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async =>
      _next();

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      Stream<Position>.periodic(const Duration(seconds: 2), (_) => _next());

  @override
  Stream<ServiceStatus> getServiceStatusStream() =>
      Stream<ServiceStatus>.value(ServiceStatus.enabled);

  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() async =>
      LocationAccuracyStatus.precise;

  @override
  Future<LocationAccuracyStatus> requestTemporaryFullAccuracy({
    required String purposeKey,
  }) async =>
      LocationAccuracyStatus.precise;

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> openLocationSettings() async => false;
}

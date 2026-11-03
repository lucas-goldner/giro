import 'package:flutter/widgets.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';

/// Placeholder for platforms without Flutter GPU (the web); never built.
class MapLibreMapView extends StatelessWidget {
  const MapLibreMapView({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.fogOfWar = true,
    this.revealRadiusMeters = 90,
    this.pointRadiusMeters = 72,
    this.onLongPress,
    this.onCameraMove,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<MapMarker> markers;
  final Set<MapPolyline> polylines;
  final bool myLocationEnabled;
  final bool compassEnabled;
  final bool fogOfWar;
  final double revealRadiusMeters;
  final double pointRadiusMeters;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;

  @override
  Widget build(BuildContext context) =>
      throw UnsupportedError('MapLibre Flutter GPU is not available here');
}

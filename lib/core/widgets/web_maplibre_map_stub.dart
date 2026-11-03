import 'package:flutter/widgets.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';

/// Placeholder for non-web platforms; never built.
class WebMapLibreMap extends StatelessWidget {
  const WebMapLibreMap({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.onLongPress,
    this.onCameraMove,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<MapMarker> markers;
  final Set<MapPolyline> polylines;
  final bool myLocationEnabled;
  final bool compassEnabled;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;

  @override
  Widget build(BuildContext context) =>
      throw UnsupportedError('MapLibre GL JS is only available on the web');
}

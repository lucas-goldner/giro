import 'package:giro/core/model/walk_route.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Route lines in the Sonic register: a soft sky glow under an electric
/// blue line. Both go through the fog of war, which uncovers the map
/// around them.
abstract final class SonicMap {
  static Set<Polyline> polylines(
    Iterable<WalkRoute> routes, {
    bool faint = false,
  }) => {
    for (final route in routes) ...[
      Polyline(
        polylineId: PolylineId('glow_${route.id}'),
        points: route.coordinates,
        color: SonicTheme.sky.withValues(alpha: faint ? 0.18 : 0.45),
        width: 14,
      ),
      Polyline(
        polylineId: PolylineId('route_${route.id}'),
        points: route.coordinates,
        color: faint ? SonicTheme.outline : SonicTheme.blue,
        width: 5,
      ),
    ],
  };

  static Set<Polyline> live(List<LatLng> points) => {
    Polyline(
      polylineId: PolylineId('live_glow'),
      points: points,
      color: SonicTheme.sky.withValues(alpha: 0.5),
      width: 16,
    ),
    Polyline(
      polylineId: PolylineId('live'),
      points: points,
      color: SonicTheme.blue,
      width: 6,
    ),
  };

  static const LatLng tokyo = LatLng(35.682839, 139.759455);
}

import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Route lines in the Sonic register: a soft sky glow under an electric
/// blue line. Both go through the fog of war, which uncovers the map
/// around them.
abstract final class SonicMap {
  static Set<MapPolyline> polylines(
    Iterable<WalkRoute> routes, {
    bool faint = false,
  }) => {
    for (final route in routes) ...[
      MapPolyline(
        id: 'glow_${route.id}',
        points: route.coordinates,
        color: SonicTheme.sky.withValues(alpha: faint ? 0.18 : 0.45),
        width: 14,
      ),
      MapPolyline(
        id: 'route_${route.id}',
        points: route.coordinates,
        color: faint ? SonicTheme.outline : SonicTheme.blue,
        width: 5,
      ),
    ],
  };

  static Set<MapPolyline> live(List<LatLng> points) => {
    MapPolyline(
      id: 'live_glow',
      points: points,
      color: SonicTheme.sky.withValues(alpha: 0.5),
      width: 16,
    ),
    MapPolyline(id: 'live', points: points, width: 6),
  };

  static const LatLng tokyo = LatLng(35.682839, 139.759455);
}

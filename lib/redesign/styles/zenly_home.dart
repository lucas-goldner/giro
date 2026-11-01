import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/redesign/redesign_actions.dart';
import 'package:giro/redesign/route_preview.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Zenly": the map is washed in a warm yellow-to-pink gradient, the place
/// name is a giant lowercase underlined heading, controls are black rounded
/// squares with gradient icons, and content sits on black cards with bold
/// white type and one gradient pill. Loud colour, but only three surfaces:
/// gradient, black, white.
class ZenlyHome extends StatelessWidget {
  const ZenlyHome({super.key});

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7CF7C4), Color(0xFFFFE45C), Color(0xFFFF8FB1)],
  );

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.zenly.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final latest = routes.firstOrNull;
    final time = formatDuration(routes.totalDuration).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFFE45C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PlatformMapView(
            initialCameraPosition: CameraPosition(
              target: routes.isNotEmpty
                  ? routes.first.coordinates.first
                  : const LatLng(35.682839, 139.759455),
              zoom: 15,
            ),
            polylines: {
              for (final route in routes)
                Polyline(
                  polylineId: PolylineId('route_${route.id}'),
                  width: 6,
                  points: route.coordinates,
                ),
            },
            markers: {
              for (final poi in pois)
                Marker(markerId: MarkerId(poi.id), position: poi.coordinates),
            },
          ),
          // The Zenly wash: a translucent warm gradient over the whole map.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFE45C).withValues(alpha: 0.28),
                    const Color(0xFFFFE45C).withValues(alpha: 0.12),
                    const Color(0xFFFF8FB1).withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'tokyo\nwalks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.5,
                          height: 0.95,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.4,
                        ),
                      ),
                    ),
                    _SquareButton(
                      icon: Icons.person_rounded,
                      onTap: () {},
                      size: 44,
                    ),
                    const SizedBox(width: 8),
                    _SquareButton(
                      icon: Icons.settings_rounded,
                      onTap: () {},
                      size: 44,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SquareButton(
                      icon: Icons.directions_walk_rounded,
                      label: 'Record',
                      onTap: () => RedesignActions.record(context),
                      gradientIcon: true,
                    ),
                    const SizedBox(width: 14),
                    _SquareButton(
                      icon: Icons.favorite_rounded,
                      label: 'Import',
                      onTap: () => RedesignActions.import(context),
                      gradientIcon: true,
                    ),
                    const SizedBox(width: 14),
                    _SquareButton(
                      icon: Icons.place_rounded,
                      label: 'Places',
                      onTap: () => RedesignActions.places(context),
                      gradientIcon: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatDistance(routes.totalDistanceMeters)} '
                          'this week',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${routes.length} WALKS · '
                          '$time',
                          style: const TextStyle(
                            color: Color(0xFF7CF7C4),
                            fontSize: 12,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (latest != null) ...[
                          const SizedBox(height: 14),
                          _LatestWalk(palette: palette, route: latest),
                        ],
                        const SizedBox(height: 14),
                        _GradientPill(
                          label: 'ALL WALKS',
                          icon: Icons.route_rounded,
                          onTap: () => RedesignActions.walks(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.size = 64,
    this.gradientIcon = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final double size;
  final bool gradientIcon;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: Colors.white, size: size * 0.46);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(size * 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(size * 0.3),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: gradientIcon
                  ? ShaderMask(
                      shaderCallback: (bounds) =>
                          ZenlyHome.gradient.createShader(bounds),
                      child: iconWidget,
                    )
                  : iconWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestWalk extends StatelessWidget {
  const _LatestWalk({required this.palette, required this.route});

  final RedesignPalette palette;
  final WalkRoute route;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () => context.navigator.pushNamed(
      RouteDetailPage.routeName,
      arguments: route,
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RoutePreview(
                  points: route.coordinates,
                  color: const Color(0xFFFF8FB1),
                  background: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'latest walk',
                    style: TextStyle(
                      color: palette.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${route.distanceLabel} · ${route.durationLabel}',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: palette.ink, size: 20),
          ],
        ),
      ),
    ),
  );
}

class _GradientPill extends StatelessWidget {
  const _GradientPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'All walks',
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: ZenlyHome.gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

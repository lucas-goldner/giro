import 'dart:math' as math;

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

/// "Outdoor": the komoot / AllTrails family. Sand-coloured paper with faint
/// contour lines, forest green, chunky pill buttons and soft cards. Feels
/// like a trail map rather than a dashboard, but stays airy.
class OutdoorHome extends StatelessWidget {
  const OutdoorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.outdoor.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final distance = formatDistance(routes.totalDistanceMeters);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ContourPainter(palette.primary)),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Good morning',
                  style: TextStyle(color: palette.muted, fontSize: 15),
                ),
                Text(
                  'Explore Tokyo on foot',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(palette.radius),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(palette.radius),
                    child: SizedBox(
                      height: 250,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PlatformMapView(
                            initialCameraPosition: CameraPosition(
                              target: routes.isNotEmpty
                                  ? routes.first.coordinates.first
                                  : const LatLng(35.682839, 139.759455),
                              zoom: 14.5,
                            ),
                            polylines: {
                              for (final route in routes)
                                Polyline(
                                  polylineId: PolylineId('route_${route.id}'),
                                  color: palette.primary,
                                  width: 4,
                                  points: route.coordinates,
                                ),
                            },
                            markers: {
                              for (final poi in pois)
                                Marker(
                                  markerId: MarkerId(poi.id),
                                  position: poi.coordinates,
                                ),
                            },
                          ),
                          Positioned(
                            left: 12,
                            top: 12,
                            child: _Badge(
                              palette: palette,
                              text:
                                  '${routes.length} walks · '
                                  '$distance'
                                  ' this week',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Pill(
                  palette: palette,
                  filled: true,
                  icon: Icons.directions_walk_rounded,
                  label: 'Start a walk',
                  onTap: () => RedesignActions.record(context),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Pill(
                        palette: palette,
                        icon: Icons.favorite_border_rounded,
                        label: 'Import',
                        onTap: () => RedesignActions.import(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Pill(
                        palette: palette,
                        icon: Icons.place_outlined,
                        label: 'Places',
                        onTap: () => RedesignActions.places(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Recent walks',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    Semantics(
                      button: true,
                      label: 'All walks',
                      child: InkWell(
                        onTap: () => RedesignActions.walks(context),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: ExcludeSemantics(
                            child: Text(
                              'All walks',
                              style: TextStyle(
                                color: palette.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final route in routes.take(3)) ...[
                  _WalkCard(palette: palette, route: route),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint topographic contour lines, the signature of trail maps.
class _ContourPainter extends CustomPainter {
  _ContourPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final random = math.Random(7);
    for (var i = 0; i < 9; i++) {
      final cx = size.width * (0.15 + random.nextDouble() * 0.7);
      final cy = size.height * (0.1 + random.nextDouble() * 0.8);
      for (var ring = 1; ring <= 5; ring++) {
        final path = Path();
        const steps = 48;
        for (var s = 0; s <= steps; s++) {
          final t = s / steps * 2 * math.pi;
          final wobble = 1 + 0.18 * math.sin(3 * t + i) + 0.1 * math.cos(5 * t);
          final r = ring * 26.0 * wobble;
          final point = Offset(
            cx + r * math.cos(t),
            cy + r * 0.7 * math.sin(t),
          );
          if (s == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ContourPainter oldDelegate) => oldDelegate.color != color;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.palette, required this.text});

  final RedesignPalette palette;
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Text(
        text,
        style: TextStyle(
          color: palette.ink,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final RedesignPalette palette;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : palette.primary;
    return Material(
      color: filled ? palette.primary : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : BorderSide(color: palette.primary, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkCard extends StatelessWidget {
  const _WalkCard({required this.palette, required this.route});

  final RedesignPalette palette;
  final WalkRoute route;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.surface,
    borderRadius: BorderRadius.circular(palette.radius),
    child: InkWell(
      borderRadius: BorderRadius.circular(palette.radius),
      onTap: () => context.navigator.pushNamed(
        RouteDetailPage.routeName,
        arguments: route,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RoutePreview(
                  points: route.coordinates,
                  color: palette.primary,
                  background: palette.background,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.startDate.toLocalizedString(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${route.distanceLabel} · ${route.durationLabel}',
                    style: TextStyle(color: palette.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: palette.primary, size: 20),
          ],
        ),
      ),
    ),
  );
}

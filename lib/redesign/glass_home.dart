import 'dart:ui';

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

/// Variation B, "Glass": dark, iOS-native feel. A gradient scrim carries a
/// large title, a frosted panel holds a Walks / Places switch with the
/// latest entries, and one electric-blue button starts a walk.
class GlassHome extends StatefulWidget {
  const GlassHome({super.key});

  @override
  State<GlassHome> createState() => _GlassHomeState();
}

class _GlassHomeState extends State<GlassHome> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.glass.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: PlatformMapView(
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
                    color: palette.accent,
                    width: 4,
                    points: route.coordinates,
                  ),
              },
              markers: {
                for (final poi in pois)
                  Marker(markerId: MarkerId(poi.id), position: poi.coordinates),
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.background.withValues(alpha: 0.95),
                      palette.background.withValues(alpha: 0),
                    ],
                  ),
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
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giro',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Tokyo · ${routes.length} walks · '
                          '${formatDistance(routes.totalDistanceMeters)}',
                          style: TextStyle(color: palette.muted, fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _GlassIconButton(
                      palette: palette,
                      icon: Icons.favorite_border_rounded,
                      onTap: () => RedesignActions.import(context),
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
            child: _GlassPanel(
              palette: palette,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Segmented(
                    palette: palette,
                    index: _segment,
                    labels: const ['Walks', 'Places'],
                    onChanged: (index) => setState(() => _segment = index),
                  ),
                  const SizedBox(height: 12),
                  if (_segment == 0)
                    for (final route in routes.take(2))
                      _WalkRow(palette: palette, route: route)
                  else
                    for (final poi in pois.take(3))
                      _PlaceRow(palette: palette, name: poi.name),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _PrimaryButton(
                          palette: palette,
                          label: 'Start a walk',
                          icon: Icons.play_arrow_rounded,
                          onTap: () => RedesignActions.record(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _GhostButton(
                        palette: palette,
                        label: _segment == 0 ? 'See all' : 'All places',
                        onTap: () => _segment == 0
                            ? RedesignActions.walks(context)
                            : RedesignActions.places(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.palette, required this.child});

  final RedesignPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(palette.radius + 8),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(palette.radius + 8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    ),
  );
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.palette,
    required this.icon,
    required this.onTap,
  });

  final RedesignPalette palette;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.surface.withValues(alpha: 0.8),
    shape: CircleBorder(
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: palette.ink, size: 22),
      ),
    ),
  );
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.palette,
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  final RedesignPalette palette;
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 34,
                  decoration: BoxDecoration(
                    color: i == index ? palette.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == index ? palette.ink : palette.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _WalkRow extends StatelessWidget {
  const _WalkRow({required this.palette, required this.route});

  final RedesignPalette palette;
  final WalkRoute route;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => context.navigator.pushNamed(
      RouteDetailPage.routeName,
      arguments: route,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RoutePreview(
                points: route.coordinates,
                color: palette.accent,
                background: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${route.distanceLabel} · ${route.durationLabel}',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.muted),
        ],
      ),
    ),
  );
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.palette, required this.name});

  final RedesignPalette palette;
  final String name;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      children: [
        Icon(Icons.place_rounded, color: palette.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(color: palette.ink, fontWeight: FontWeight.w600),
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: palette.muted),
      ],
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.palette,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final RedesignPalette palette;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.accent,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.palette,
    required this.label,
    required this.onTap,
  });

  final RedesignPalette palette;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: palette.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    ),
  );
}

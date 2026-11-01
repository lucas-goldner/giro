import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/redesign/redesign_actions.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Variation C, "Blocks": a playful dashboard. Big greeting, three colour
/// stat tiles, the map framed as a card with the last walk, and a 2x2 grid
/// of chunky actions. Feels more like a fitness app than a map viewer.
class BlocksHome extends StatelessWidget {
  const BlocksHome({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.blocks.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final latest = routes.firstOrNull;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey Lucas 👋',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'Ready for a walk?',
                style: TextStyle(color: palette.muted, fontSize: 16),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StatTile(
                    color: palette.accent,
                    value: '${routes.length}',
                    label: 'walks',
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    color: palette.primary,
                    value: formatDistance(routes.totalDistanceMeters),
                    label: 'walked',
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    color: const Color(0xFF7B61FF),
                    value: formatDuration(routes.totalDuration),
                    label: 'on foot',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MapCard(
                palette: palette,
                onTap: latest == null
                    ? null
                    : () => context.navigator.pushNamed(
                        RouteDetailPage.routeName,
                        arguments: latest,
                      ),
                label: latest == null
                    ? 'No walks yet'
                    : 'Last walk · '
                          '${latest.startDate.toLocalizedString(context)}',
                child: PlatformMapView(
                  initialCameraPosition: CameraPosition(
                    target:
                        latest?.coordinates.first ??
                        const LatLng(35.682839, 139.759455),
                    zoom: 14.5,
                  ),
                  polylines: {
                    if (latest != null)
                      Polyline(
                        polylineId: PolylineId('route_${latest.id}'),
                        color: palette.accent,
                        width: 5,
                        points: latest.coordinates,
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
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      palette: palette,
                      color: palette.accent,
                      icon: Icons.directions_walk_rounded,
                      title: 'Record',
                      subtitle: 'Start a new walk',
                      height: 150,
                      onTap: () => RedesignActions.record(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        _ActionTile(
                          palette: palette,
                          color: palette.surface,
                          dark: false,
                          icon: Icons.favorite_rounded,
                          title: 'Import',
                          subtitle: 'From Health',
                          height: 69,
                          onTap: () => RedesignActions.import(context),
                        ),
                        const SizedBox(height: 12),
                        _ActionTile(
                          palette: palette,
                          color: palette.surface,
                          dark: false,
                          icon: Icons.place_rounded,
                          title: 'Places',
                          subtitle: '${pois.length} saved',
                          height: 69,
                          onTap: () => RedesignActions.places(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ActionTile(
                palette: palette,
                color: const Color(0xFFFFD166),
                dark: false,
                icon: Icons.route_rounded,
                title: 'All walks',
                subtitle: '${routes.length} recorded',
                height: 69,
                horizontal: true,
                onTap: () => RedesignActions.walks(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.color,
    required this.value,
    required this.label,
  });

  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.palette,
    required this.child,
    required this.label,
    required this.onTap,
  });

  final RedesignPalette palette;
  final Widget child;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 250,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(palette.radius),
        border: Border.all(color: palette.ink, width: 3),
        boxShadow: [BoxShadow(color: palette.ink, offset: const Offset(6, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(palette.radius - 3),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 12,
              bottom: 12,
              child: Material(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (onTap != null)
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: palette.ink,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.palette,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.height,
    required this.onTap,
    this.dark = true,
    this.horizontal = false,
  });

  final RedesignPalette palette;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final double height;
  final VoidCallback onTap;
  final bool dark;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : palette.ink;
    final texts = [
      Text(
        title,
        style: TextStyle(
          color: foreground,
          fontSize: horizontal ? 17 : 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        subtitle,
        style: TextStyle(
          color: foreground.withValues(alpha: 0.75),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
    return SizedBox(
      height: height,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: horizontal || height < 90
                ? Row(
                    children: [
                      Icon(icon, color: foreground, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: texts,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: foreground, size: 34),
                      const Spacer(),
                      ...texts,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

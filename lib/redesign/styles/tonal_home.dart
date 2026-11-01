import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/redesign/redesign_actions.dart';
import 'package:giro/redesign/route_preview.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Tonal": Material You. Everything is a tint of one seed colour: layered
/// pastel surfaces instead of lines or shadows, 28px radii, tonal chips and
/// an extended FAB. Calm because there is no pure white or black anywhere.
class TonalHome extends StatelessWidget {
  const TonalHome({super.key});

  static final ColorScheme _scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5B4B9E),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = _scheme;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;

    return Theme(
      data: ThemeData(colorScheme: scheme, useMaterial3: true),
      child: Scaffold(
        backgroundColor: scheme.surface,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => RedesignActions.record(context),
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          icon: const Icon(Icons.directions_walk_rounded),
          label: const Text('Record walk'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                child: Row(
                  children: [
                    Text(
                      'Giro',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        color: scheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: 240,
                  child: PlatformMapView(
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
                          color: scheme.primary,
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
                ),
              ),
              const SizedBox(height: 12),
              _TonalCard(
                color: scheme.primaryContainer,
                child: Row(
                  children: [
                    _Stat(
                      scheme: scheme,
                      value: '${routes.length}',
                      label: 'walks this week',
                    ),
                    _Stat(
                      scheme: scheme,
                      value: formatDistance(routes.totalDistanceMeters),
                      label: 'distance',
                    ),
                    _Stat(
                      scheme: scheme,
                      value: formatDuration(routes.totalDuration),
                      label: 'time',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Chip(
                    scheme: scheme,
                    icon: Icons.favorite_rounded,
                    label: 'Import',
                    onTap: () => RedesignActions.import(context),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    scheme: scheme,
                    icon: Icons.place_rounded,
                    label: 'Places',
                    onTap: () => RedesignActions.places(context),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    scheme: scheme,
                    icon: Icons.list_rounded,
                    label: 'All walks',
                    onTap: () => RedesignActions.walks(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Recent walks',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final (index, route) in routes.take(3).indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _WalkTile(
                    scheme: scheme,
                    route: route,
                    first: index == 0,
                    last: index == routes.take(3).length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TonalCard extends StatelessWidget {
  const _TonalCard({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.scheme, required this.value, required this.label});

  final ColorScheme scheme;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.scheme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final ColorScheme scheme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: label,
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: scheme.onSecondaryContainer),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: scheme.onSecondaryContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

class _WalkTile extends StatelessWidget {
  const _WalkTile({
    required this.scheme,
    required this.route,
    required this.first,
    required this.last,
  });

  final ColorScheme scheme;
  final WalkRoute route;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? 24 : 8),
      bottom: Radius.circular(last ? 24 : 8),
    );
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => context.navigator.pushNamed(
          RouteDetailPage.routeName,
          arguments: route,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RoutePreview(
                    points: route.coordinates,
                    color: scheme.primary,
                    background: scheme.surfaceContainerLowest,
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
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${route.distanceLabel} · ${route.durationLabel}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

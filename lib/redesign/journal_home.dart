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

/// Variation A, "Journal": the map stays the hero, a warm paper-like sheet
/// shows the week at a glance with recent walks as little route sketches,
/// and recording is the one big terracotta button.
class JournalHome extends StatelessWidget {
  const JournalHome({super.key});

  static const _sheetHeight = 332.0;

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.journal.palette;
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
                    color: palette.primary,
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
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    _Pill(
                      palette: palette,
                      child: Row(
                        children: [
                          Icon(Icons.hiking_rounded, color: palette.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Giro',
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _Pill(
                      palette: palette,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _sheetHeight,
            child: _JournalSheet(palette: palette, routes: routes),
          ),
          Positioned(
            right: 20,
            bottom: _sheetHeight - 30,
            child: _RecordButton(palette: palette),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.palette, required this.child});

  final RedesignPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: child,
    ),
  );
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.palette});

  final RedesignPalette palette;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.accent,
    shape: const CircleBorder(),
    elevation: 8,
    shadowColor: palette.accent.withValues(alpha: 0.5),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => RedesignActions.record(context),
      child: const SizedBox(
        width: 64,
        height: 64,
        child: Icon(
          Icons.directions_walk_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    ),
  );
}

class _JournalSheet extends StatelessWidget {
  const _JournalSheet({required this.palette, required this.routes});

  final RedesignPalette palette;
  final List<WalkRoute> routes;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.background,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(palette.radius + 6),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 30,
          offset: const Offset(0, -8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: palette.muted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 100, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This week',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${routes.length} walks · '
                '${formatDistance(routes.totalDistanceMeters)} · '
                '${formatDuration(routes.totalDuration)}',
                style: TextStyle(color: palette.muted, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 128,
          child: routes.isEmpty
              ? _EmptyWalks(palette: palette)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: routes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _WalkCard(palette: palette, route: routes[index]),
                ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _Chip(
                palette: palette,
                icon: Icons.favorite_border_rounded,
                label: 'Import',
                onTap: () => RedesignActions.import(context),
              ),
              const SizedBox(width: 10),
              _Chip(
                palette: palette,
                icon: Icons.place_outlined,
                label: 'Places',
                onTap: () => RedesignActions.places(context),
              ),
              const SizedBox(width: 10),
              _Chip(
                palette: palette,
                icon: Icons.list_rounded,
                label: 'All walks',
                onTap: () => RedesignActions.walks(context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyWalks extends StatelessWidget {
  const _EmptyWalks({required this.palette});

  final RedesignPalette palette;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'No walks yet. Record one or import from Health.',
      style: TextStyle(color: palette.muted),
    ),
  );
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
      child: SizedBox(
        width: 168,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RoutePreview(
                    points: route.coordinates,
                    color: palette.primary,
                    background: palette.background,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _shortDate(route.startDate),
                      style: TextStyle(
                        color: palette.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      route.distanceLabel,
                      style: TextStyle(
                        color: palette.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      route.durationLabel,
                      style: TextStyle(color: palette.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final RedesignPalette palette;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: palette.ink.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: palette.ink),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

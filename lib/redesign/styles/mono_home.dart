import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/redesign/redesign_actions.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Mono": the Oura / WHOOP register. Pure black, thin light type, 1px
/// graphite rules, numbers as the only large elements, and the single cyan
/// kept for the route on the map. One inverted white button.
class MonoHome extends StatelessWidget {
  const MonoHome({super.key});

  static const _line = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.mono.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  Text(
                    'Giro',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.person_outline_rounded, color: palette.muted),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 236,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: _line),
                      borderRadius: BorderRadius.circular(18),
                    ),
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
                            color: palette.accent,
                            width: 3,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'THIS WEEK',
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (routes.totalDistanceMeters / 1000).toStringAsFixed(1),
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'km',
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _MiniStat(
                    palette: palette,
                    value: '${routes.length}',
                    label: 'WALKS',
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: _line,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _MiniStat(
                    palette: palette,
                    value: formatDuration(routes.totalDuration),
                    label: 'TIME',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: _line),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final route in routes.take(3)) ...[
                    _WalkRow(palette: palette, route: route),
                    const Divider(height: 1, color: _line),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  Material(
                    color: palette.ink,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => RedesignActions.record(context),
                      child: const SizedBox(
                        height: 52,
                        child: Center(
                          child: Text(
                            'Record walk',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Ghost(
                        palette: palette,
                        label: 'Import',
                        onTap: () => RedesignActions.import(context),
                      ),
                      _Ghost(
                        palette: palette,
                        label: 'Places',
                        onTap: () => RedesignActions.places(context),
                      ),
                      _Ghost(
                        palette: palette,
                        label: 'All walks',
                        onTap: () => RedesignActions.walks(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.palette,
    required this.value,
    required this.label,
  });

  final RedesignPalette palette;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: palette.ink,
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: palette.muted,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _WalkRow extends StatelessWidget {
  const _WalkRow({required this.palette, required this.route});

  final RedesignPalette palette;
  final WalkRoute route;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.navigator.pushNamed(
      RouteDetailPage.routeName,
      arguments: route,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              route.startDate.toLocalizedString(context),
              style: TextStyle(
                color: palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '${route.distanceLabel}  ·  ${route.durationLabel}',
            style: TextStyle(color: palette.muted, fontSize: 14),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right_rounded, color: palette.muted, size: 20),
        ],
      ),
    ),
  );
}

class _Ghost extends StatelessWidget {
  const _Ghost({
    required this.palette,
    required this.label,
    required this.onTap,
  });

  final RedesignPalette palette;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(foregroundColor: palette.muted),
    child: Text(label),
  );
}

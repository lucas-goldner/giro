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

/// "Swiss": International Typographic Style. Monochrome, a strict grid,
/// hairline rules, one very large numeral, and a single red for the one
/// action that matters. No cards, no shadows, no rounded corners.
class SwissHome extends StatelessWidget {
  const SwissHome({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.swiss.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final time = formatDuration(routes.totalDuration).toUpperCase();

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 9,
            child: Stack(
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
                        color: palette.ink,
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
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        children: [
                          _Tag(text: 'GIRO', palette: palette),
                          const Spacer(),
                          _Tag(text: 'TOKYO', palette: palette),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Rule(palette.ink, thickness: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _kmNumber(routes.totalDistanceMeters),
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -4,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'km',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'THIS WEEK\n${routes.length} WALKS · '
                          '$time',
                          textAlign: TextAlign.right,
                          style: _label(palette.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Rule(palette.ink),
                Row(
                  children: [
                    _TextAction(
                      label: 'RECORD',
                      color: palette.accent,
                      palette: palette,
                      onTap: () => RedesignActions.record(context),
                    ),
                    _TextAction(
                      label: 'IMPORT',
                      color: palette.ink,
                      palette: palette,
                      onTap: () => RedesignActions.import(context),
                    ),
                    _TextAction(
                      label: 'PLACES',
                      color: palette.ink,
                      palette: palette,
                      onTap: () => RedesignActions.places(context),
                    ),
                    _TextAction(
                      label: 'ALL WALKS',
                      color: palette.ink,
                      palette: palette,
                      onTap: () => RedesignActions.walks(context),
                      last: true,
                    ),
                  ],
                ),
                _Rule(palette.ink),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final route in routes.take(3)) ...[
                        _WalkRow(palette: palette, route: route),
                        _Rule(palette.muted.withValues(alpha: 0.35)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _kmNumber(double meters) => (meters / 1000).toStringAsFixed(1);
}

TextStyle _label(Color color) => TextStyle(
  color: color,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.2,
  height: 1.4,
);

class _Rule extends StatelessWidget {
  const _Rule(this.color, {this.thickness = 1});

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) =>
      Container(height: thickness, color: color);
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.palette});

  final String text;
  final RedesignPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    color: palette.background,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Text(text, style: _label(palette.ink)),
  );
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.palette,
    required this.onTap,
    this.last = false,
  });

  final String label;
  final Color color;
  final RedesignPalette palette;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: label[0] + label.substring(1).toLowerCase(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: last ? null : Border(right: BorderSide(color: palette.ink)),
          ),
          child: ExcludeSemantics(child: Text(label, style: _label(color))),
        ),
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
    onTap: () => context.navigator.pushNamed(
      RouteDetailPage.routeName,
      arguments: route,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              route.startDate.toLocalizedString(context),
              style: TextStyle(
                color: palette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            route.distanceLabel,
            style: TextStyle(color: palette.ink, fontSize: 16),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 44,
            child: Text(
              route.durationLabel,
              textAlign: TextAlign.right,
              style: TextStyle(color: palette.muted, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}

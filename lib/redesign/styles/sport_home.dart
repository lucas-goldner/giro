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

/// "Sport": the Nike Run Club register. White, a bold title with plain text
/// tabs, a stats card, the map faded out at both ends, and one enormous
/// volt-yellow START circle with small white satellites. Energy comes from
/// scale and the single yellow, not from decoration.
class SportHome extends StatefulWidget {
  const SportHome({super.key});

  @override
  State<SportHome> createState() => _SportHomeState();
}

class _SportHomeState extends State<SportHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final palette = DesignVariant.sport.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: palette.surface,
                    child: Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: palette.ink,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.bookmark_border_rounded, color: palette.ink),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                'Walk',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  _Tab(
                    label: 'Start a walk',
                    active: _tab == 0,
                    palette: palette,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  const SizedBox(width: 20),
                  _Tab(
                    label: 'Past walks',
                    active: _tab == 1,
                    palette: palette,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _tab == 0
                  ? _StartTab(palette: palette, routes: routes, pois: pois)
                  : _PastWalksTab(palette: palette, routes: routes),
            ),
            _TabBar(palette: palette),
          ],
        ),
      ),
    );
  }
}

class _StartTab extends StatelessWidget {
  const _StartTab({
    required this.palette,
    required this.routes,
    required this.pois,
  });

  final RedesignPalette palette;
  final List<WalkRoute> routes;
  final List<dynamic> pois;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _StatsCard(palette: palette, routes: routes),
      ),
      Expanded(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PlatformMapView(
              initialCameraPosition: CameraPosition(
                target: routes.isNotEmpty
                    ? routes.first.coordinates.first
                    : const LatLng(35.682839, 139.759455),
                zoom: 14,
              ),
              polylines: {
                for (final route in routes)
                  Polyline(
                    polylineId: PolylineId('route_${route.id}'),
                    color: palette.ink,
                    width: 3,
                    points: route.coordinates,
                  ),
              },
            ),
            // Fade the map into the page at the top and bottom, as NRC does.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.3, 0.6, 1],
                    colors: [
                      palette.background,
                      palette.background.withValues(alpha: 0.55),
                      palette.background.withValues(alpha: 0.55),
                      palette.background,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.55),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Satellite(
                    icon: Icons.favorite_rounded,
                    label: 'Import',
                    onTap: () => RedesignActions.import(context),
                  ),
                  const SizedBox(width: 26),
                  _StartButton(
                    palette: palette,
                    onTap: () => RedesignActions.record(context),
                  ),
                  const SizedBox(width: 26),
                  _Satellite(
                    icon: Icons.place_rounded,
                    label: 'Places',
                    onTap: () => RedesignActions.places(context),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.98),
              child: Semantics(
                button: true,
                label: 'All walks',
                child: Material(
                  color: palette.background,
                  shape: const StadiumBorder(),
                  elevation: 3,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => RedesignActions.walks(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      child: ExcludeSemantics(
                        child: Text(
                          'All walks',
                          style: TextStyle(
                            color: palette.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.palette, required this.routes});

  final RedesignPalette palette;
  final List<WalkRoute> routes;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.background,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: routes.isEmpty
                  ? ColoredBox(color: palette.surface)
                  : RoutePreview(
                      points: routes.first.coordinates,
                      color: palette.ink,
                      background: palette.surface,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This week',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
                Text(
                  '${formatDistance(routes.totalDistanceMeters)} walked',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  '${routes.length} walks · '
                  '${formatDuration(routes.totalDuration)}',
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.palette, required this.onTap});

  final RedesignPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Record',
    child: Material(
      color: palette.accent,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: palette.accent.withValues(alpha: 0.6),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 118,
          height: 118,
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                'START',
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Satellite extends StatelessWidget {
  const _Satellite({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.black, size: 22),
        ),
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool active;
  final RedesignPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: active ? palette.ink : palette.muted,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _PastWalksTab extends StatelessWidget {
  const _PastWalksTab({required this.palette, required this.routes});

  final RedesignPalette palette;
  final List<WalkRoute> routes;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
    children: [
      for (final route in routes)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.navigator.pushNamed(
              RouteDetailPage.routeName,
              arguments: route,
            ),
            child: _StatsRow(palette: palette, route: route),
          ),
        ),
    ],
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.palette, required this.route});

  final RedesignPalette palette;
  final WalkRoute route;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: RoutePreview(
              points: route.coordinates,
              color: palette.ink,
              background: palette.surface,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.startDate.toLocalizedString(context),
                  style: TextStyle(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Figure(value: route.distanceLabel, label: 'Distance'),
                    const SizedBox(width: 18),
                    _Figure(value: route.durationLabel, label: 'Time'),
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

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
      ),
    ],
  );
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.palette});

  final RedesignPalette palette;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: palette.surface, width: 1.5)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.home_outlined,
            label: 'Home',
            active: true,
            palette: palette,
            onTap: () {},
          ),
          _TabItem(
            icon: Icons.route_outlined,
            label: 'Walks',
            palette: palette,
            onTap: () => RedesignActions.walks(context),
          ),
          _TabItem(
            icon: Icons.directions_walk_rounded,
            label: 'Record',
            palette: palette,
            onTap: () => RedesignActions.record(context),
          ),
          _TabItem(
            icon: Icons.place_outlined,
            label: 'Places',
            palette: palette,
            onTap: () => RedesignActions.places(context),
          ),
          _TabItem(
            icon: Icons.favorite_border_rounded,
            label: 'Import',
            palette: palette,
            onTap: () => RedesignActions.import(context),
          ),
        ],
      ),
    ),
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.palette,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final RedesignPalette palette;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: ExcludeSemantics(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? palette.ink : palette.muted),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active ? palette.ink : palette.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

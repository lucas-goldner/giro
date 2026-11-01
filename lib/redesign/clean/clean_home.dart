import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/redesign/clean/clean_theme.dart';
import 'package:giro/redesign/clean/clean_walk_tile.dart';
import 'package:giro/redesign/redesign_actions.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Clean" home: Apple Maps-style map hero with a white sheet holding a row
/// of round icon actions and the two most recent walks. No colour blocks,
/// no title bars, one green.
class CleanHome extends StatelessWidget {
  const CleanHome({super.key});

  static const _sheetHeight = 400.0;

  @override
  Widget build(BuildContext context) {
    final palette = CleanTheme.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;

    return Scaffold(
      backgroundColor: palette.background,
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
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    _MapButton(icon: Icons.person_rounded, onTap: () {}),
                    const SizedBox(height: 10),
                    _MapButton(icon: Icons.near_me_rounded, onTap: () {}),
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
            child: _Sheet(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Walks',
                        style: CleanTheme.title.copyWith(color: palette.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This week · ${routes.length} walks · '
                        '${formatDistance(routes.totalDistanceMeters)} · '
                        '${formatDuration(routes.totalDuration)}',
                        style: CleanTheme.footnote.copyWith(
                          color: palette.muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _RoundAction(
                        icon: Icons.directions_walk_rounded,
                        label: 'Record',
                        primary: true,
                        onTap: () => RedesignActions.record(context),
                      ),
                      _RoundAction(
                        icon: Icons.favorite_rounded,
                        label: 'Import',
                        onTap: () => RedesignActions.import(context),
                      ),
                      _RoundAction(
                        icon: Icons.place_rounded,
                        label: 'Places',
                        onTap: () => RedesignActions.places(context),
                      ),
                      _RoundAction(
                        icon: Icons.list_rounded,
                        label: 'All walks',
                        onTap: () => RedesignActions.walks(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
                  child: Row(
                    children: [
                      Text(
                        'Recent',
                        style: CleanTheme.headline.copyWith(color: palette.ink),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => RedesignActions.walks(context),
                        style: TextButton.styleFrom(
                          foregroundColor: palette.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                ),
                if (routes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'Record a walk or import one from Health to see it here.',
                      style: CleanTheme.body.copyWith(color: palette.muted),
                    ),
                  ),
                for (final (index, route) in routes.take(2).indexed) ...[
                  if (index > 0) const CleanDivider(),
                  CleanWalkTile(route: route),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: CleanTheme.palette.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFC7C7CC),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        ...children,
      ],
    ),
  );
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: CleanTheme.palette.background,
    shape: const CircleBorder(),
    elevation: 3,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icon, size: 21, color: CleanTheme.palette.ink),
      ),
    ),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final palette = CleanTheme.palette;
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: primary ? palette.primary : CleanTheme.fill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: primary ? Colors.white : palette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                ExcludeSemantics(
                  child: Text(
                    label,
                    style: CleanTheme.footnote.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w500,
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
}

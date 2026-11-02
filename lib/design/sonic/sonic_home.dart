import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_actions.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_ring_dialog.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Home: the fog map is the stage, a navy striped HUD panel holds the
/// week's score (distance) with its rank, and GO! is the one red button.
class SonicHome extends StatelessWidget {
  const SonicHome({super.key});

  Future<void> _addPlace(BuildContext context, LatLng location) async {
    final poi = await showSonicRingDialog(context, location);
    if (poi != null && context.mounted) {
      context.read<PoiCubit>().addPOI(poi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final totalMeters = routes.totalDistanceMeters;

    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlatformMapView(
                  initialCameraPosition: CameraPosition(
                    target: routes.isNotEmpty
                        ? routes.first.coordinates.first
                        : SonicMap.tokyo,
                    zoom: 15,
                  ),
                  polylines: SonicMap.polylines(routes),
                  markers: {
                    for (final poi in pois)
                      Marker(
                        markerId: MarkerId(poi.id),
                        position: poi.coordinates,
                        onTap: () => context
                            .read<LaunchableMapsCubit>()
                            .launchMapAtPOI(poi),
                      ),
                  },
                  onLongPress: (location) => _addPlace(context, location),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 14, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SonicHudText('GIRO', size: 32),
                          const Spacer(),
                          SonicRingChip(
                            onTap: () => SonicActions.places(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SonicRingIcon(),
                                const SizedBox(width: 6),
                                Text('${pois.length}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 16,
                  bottom: 14,
                  child: SonicChip('Zone 1 · Tokyo'),
                ),
              ],
            ),
          ),
          SonicPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STAGE: TOKYO · THIS WEEK', style: SonicTheme.label),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SonicHudText(SonicTheme.kilometres(totalMeters), size: 60),
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'KM',
                        style: TextStyle(
                          fontFamily: SonicTheme.font,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: 1,
                          color: SonicTheme.sky,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SonicRank(SonicStats.weekRank(totalMeters)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${routes.length} walks · '
                  '${formatDuration(routes.totalDuration)} · '
                  '${pois.length} rings',
                  style: SonicTheme.body,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 16,
                      child: SonicButton(
                        label: 'GO!',
                        caption: 'Record a walk',
                        semanticsLabel: 'Record',
                        color: SonicTheme.red,
                        shadow: SonicTheme.redDeep,
                        fontSize: 26,
                        onTap: () => SonicActions.record(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SonicButton(
                        label: 'Import',
                        caption: 'Health',
                        onTap: () => SonicActions.import(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SonicButton(
                        label: 'Rings',
                        caption: '${pois.length} places',
                        semanticsLabel: 'Places',
                        onTap: () => SonicActions.places(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SonicButton(
                        label: 'Stages',
                        caption: 'All walks',
                        semanticsLabel: 'All walks',
                        onTap: () => SonicActions.walks(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

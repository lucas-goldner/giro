import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_ring_dialog.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// "Stage clear!" result screen for one walk: rank, time, pace, how much
/// of the city it uncovered, and the rings (places) collected on it.
class SonicRouteDetail extends StatelessWidget {
  const SonicRouteDetail({required this.route, super.key});

  final WalkRoute route;

  static const _ringRadiusMeters = 400.0;

  Future<void> _addPlace(BuildContext context, LatLng location) async {
    final poi = await showSonicRingDialog(context, location);
    if (poi != null && context.mounted) {
      context.read<PoiCubit>().addPOI(poi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<WalkRoutesCubit>().state.routes;
    final pois = context.watch<PoiCubit>().state.pois;
    final rings = pois
        .where((poi) => route.distanceTo(poi.coordinates) <= _ringRadiusMeters)
        .toList();
    final newShare = SonicStats.newGroundShare(
      route,
      SonicStats.earlierThan(route, all),
    );
    final newMeters = route.distanceMeters * newShare;

    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PlatformMapView(
                  initialCameraPosition: CameraPosition(
                    target: route.coordinates.first,
                    zoom: 15.5,
                  ),
                  polylines: SonicMap.polylines([route]),
                  markers: {
                    for (final poi in rings)
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
                        children: [
                          SonicRingChip(
                            onTap: context.navigator.pop,
                            child: const Text('◀  BACK'),
                          ),
                          const Spacer(),
                          SonicRingChip(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SonicRingIcon(),
                                const SizedBox(width: 6),
                                Text('${rings.length}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SonicPanel(
              fill: true,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SonicHudText('STAGE CLEAR!', size: 38),
                  const SizedBox(height: 6),
                  Text(
                    '${route.startDate.toLocalizedString(context)} · '
                    '${route.durationLabel}',
                    style: SonicTheme.body,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SonicHudText(
                        SonicTheme.kilometres(route.distanceMeters),
                        size: 46,
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'KM',
                          style: TextStyle(
                            fontFamily: SonicTheme.font,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: 1,
                            color: SonicTheme.sky,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SonicRank(SonicStats.rankFor(newShare)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SonicRow(label: 'Time', value: route.durationLabel),
                  const SizedBox(height: 6),
                  SonicRow(label: 'Pace', value: _pace(route)),
                  const SizedBox(height: 6),
                  SonicRow(
                    label: 'New ground',
                    value:
                        '+${SonicTheme.kilometres(newMeters)} km · '
                        '${(newShare * 100).round()}%',
                    gold: true,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    rings.isEmpty ? 'NO RINGS ON THIS STAGE' : 'RINGS',
                    style: SonicTheme.label,
                  ),
                  if (rings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Press and hold the map to drop one.',
                        style: SonicTheme.body,
                      ),
                    ),
                  for (final poi in rings)
                    InkWell(
                      onTap: () => context
                          .read<LaunchableMapsCubit>()
                          .launchMapAtPOI(poi),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            const SonicRingIcon(size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                poi.name,
                                style: const TextStyle(
                                  color: SonicTheme.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                              color: SonicTheme.sky,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SonicButton(
                    label: 'Back to stage select',
                    caption: 'All walks',
                    semanticsLabel: 'All walks',
                    onTap: context.navigator.pop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _pace(WalkRoute route) {
    if (route.distanceMeters < 20) {
      return '--:--';
    }
    final secondsPerKm =
        route.duration.inSeconds / (route.distanceMeters / 1000);
    final minutes = (secondsPerKm ~/ 60).clamp(0, 99);
    final seconds = (secondsPerKm % 60).round().toString().padLeft(2, '0');
    return '$minutes:$seconds /KM';
  }
}

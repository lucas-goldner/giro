import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/map_settings_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/map/scenery/landmarks.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_spot_dialog.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';

/// "Stage clear!" result screen for one walk: rank, time, pace, how much
/// of the city it uncovered, and the spots (places) visited on it.
class SonicRouteDetail extends StatelessWidget {
  const SonicRouteDetail({required this.route, super.key});

  final WalkRoute route;

  static const _spotRadiusMeters = 400.0;

  Future<void> _addPlace(BuildContext context, LatLng location) async {
    final poi = await showSonicSpotDialog(context, location);
    if (poi != null && context.mounted) {
      context.read<PoiCubit>().addPOI(poi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<WalkRoutesCubit>().state.routes;
    final pois = context.watch<PoiCubit>().state.pois;
    final settings = context.watch<MapSettingsCubit>().state;
    final spots = pois
        .where((poi) => route.distanceTo(poi.coordinates) <= _spotRadiusMeters)
        .toList();
    final newShare = ExploredIndex.cached(all).newGroundShare(route);
    final newMeters = route.distanceMeters * newShare;
    final l10n = context.l10n;

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
                    tilt: SonicMap.tilt,
                  ),
                  polylines: SonicMap.polylines([route], settings: settings),
                  revealRadiusMeters: settings.revealRadiusMeters,
                  pointRadiusMeters: settings.spotRadiusMeters,
                  markers: {
                    for (final poi in spots)
                      MapMarker(
                        id: poi.id,
                        position: poi.coordinates,
                        landmark: LandmarkModel.forName(poi.name),
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
                          SonicHudChip(
                            onTap: context.navigator.pop,
                            child: Text(l10n.back),
                          ),
                          const Spacer(),
                          SonicHudChip(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SonicSpotIcon(),
                                const SizedBox(width: 6),
                                Text('${spots.length}'),
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
                  SonicHudText(l10n.stageClear, size: 38),
                  const SizedBox(height: 6),
                  Text(
                    l10n.dotSeparatedTwo(
                      route.startDate.toLocalizedString(context),
                      context.walkDuration(route.duration),
                    ),
                    style: SonicTheme.body,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SonicHudText(context.km(route.distanceMeters), size: 46),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          l10n.kmUnit,
                          style: const TextStyle(
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
                  SonicRow(
                    label: l10n.timeLabel,
                    value: context.walkDuration(route.duration),
                  ),
                  const SizedBox(height: 6),
                  SonicRow(
                    label: l10n.paceLabel,
                    value: l10n.paceValue(_pace(route)),
                  ),
                  const SizedBox(height: 6),
                  SonicRow(
                    label: l10n.newGroundLabel,
                    value: l10n.newGroundValue(
                      context.km(newMeters),
                      (newShare * 100).round(),
                    ),
                    gold: true,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    spots.isEmpty ? l10n.noSpotsOnStage : l10n.spotsHeader,
                    style: SonicTheme.label,
                  ),
                  if (spots.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(l10n.holdToMarkOne, style: SonicTheme.body),
                    ),
                  for (final poi in spots)
                    InkWell(
                      onTap: () => context
                          .read<LaunchableMapsCubit>()
                          .launchMapAtPOI(poi),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            const SonicSpotIcon(size: 16),
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
                    label: l10n.backToStageSelect,
                    caption: l10n.stagesCaption,
                    semanticsLabel: l10n.stagesCaption,
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
    return '$minutes:$seconds';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/map_settings_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/map/scenery/landmarks.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_actions.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_spot_dialog.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';

/// Home: the fog map is the stage, a navy striped HUD panel holds the
/// week's score (distance) with its rank, and GO! is the one red button.
class SonicHome extends StatelessWidget {
  const SonicHome({super.key});

  Future<void> _addPlace(BuildContext context, LatLng location) async {
    final poi = await showSonicSpotDialog(context, location);
    if (poi != null && context.mounted) {
      context.read<PoiCubit>().addPOI(poi);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final settings = context.watch<MapSettingsCubit>().state;
    final totalMeters = routes.totalDistanceMeters;
    final l10n = context.l10n;

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
                    zoom: 15.5,
                    tilt: SonicMap.tilt,
                  ),
                  polylines: SonicMap.polylines(routes, settings: settings),
                  revealRadiusMeters: settings.revealRadiusMeters,
                  pointRadiusMeters: settings.spotRadiusMeters,
                  advancedGraphics: settings.advancedGraphics,
                  markers: {
                    for (final poi in pois)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SonicHudText('GIRO', size: 32),
                          const Spacer(),
                          SonicHudChip(
                            onTap: () => SonicActions.places(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SonicSpotIcon(),
                                const SizedBox(width: 6),
                                Text('${pois.length}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SonicHudChip(
                            onTap: () => SonicActions.options(context),
                            child: Semantics(
                              label: l10n.optionsSemantics,
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: SonicTheme.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: SonicChip(l10n.zoneChip),
                ),
              ],
            ),
          ),
          SonicPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeStageLabel, style: SonicTheme.label),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Shrinks for four-digit totals instead of overflowing.
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SonicHudText(context.km(totalMeters), size: 60),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                l10n.kmUnit,
                                style: const TextStyle(
                                  fontFamily: SonicTheme.font,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                  color: SonicTheme.sky,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SonicRank(SonicStats.weekRank(totalMeters)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dotSeparated(
                    l10n.walksCount(routes.length),
                    context.walkDuration(routes.totalDuration),
                    l10n.spotsCount(pois.length),
                  ),
                  style: SonicTheme.body,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 16,
                      child: SonicButton(
                        label: l10n.goLabel,
                        caption: l10n.goCaption,
                        semanticsLabel: l10n.goSemantics,
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
                        label: l10n.importLabel,
                        caption: l10n.importCaption,
                        onTap: () => SonicActions.import(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SonicButton(
                        label: l10n.spotsLabel,
                        caption: l10n.placesCount(pois.length),
                        semanticsLabel: l10n.spotsSemantics,
                        onTap: () => SonicActions.places(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 10,
                      child: SonicButton(
                        label: l10n.stagesLabel,
                        caption: l10n.stagesCaption,
                        semanticsLabel: l10n.stagesCaption,
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

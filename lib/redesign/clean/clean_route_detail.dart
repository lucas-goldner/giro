import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/map/widgets/poi_add_dialog.dart';
import 'package:giro/redesign/clean/clean_theme.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Walk detail in the Gentler Streak / Oura mould: the map on top, then a
/// white sheet with the date, a 2x2 stat grid with micro labels, and the
/// places saved along this walk.
class CleanRouteDetail extends StatelessWidget {
  const CleanRouteDetail({required this.route, super.key});

  final WalkRoute route;

  static const _nearbyMeters = 400.0;

  void _addPlace(BuildContext context, LatLng location) =>
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => PoiAddDialog(
          location: location,
          onAdd: (poi) {
            context.read<PoiCubit>().addPOI(poi);
            dialogContext.navigator.pop();
          },
          onCancel: dialogContext.navigator.pop,
        ),
      );

  String _pace() {
    if (route.distanceMeters == 0) {
      return '–';
    }
    final secondsPerKm =
        route.duration.inSeconds / (route.distanceMeters / 1000);
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm % 60).round().toString().padLeft(2, '0');
    return '$minutes:$seconds /km';
  }

  @override
  Widget build(BuildContext context) {
    final palette = CleanTheme.palette;
    final pois = context.watch<PoiCubit>().state.pois;
    final nearby = pois
        .where((poi) => route.distanceTo(poi.coordinates) <= _nearbyMeters)
        .toList();

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PlatformMapView(
                    initialCameraPosition: CameraPosition(
                      target: route.coordinates.first,
                      zoom: 15.5,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('route_${route.id}'),
                        color: palette.primary,
                        width: 5,
                        points: route.coordinates,
                      ),
                    },
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
                ),
                Positioned(
                  top: 0,
                  left: 16,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Material(
                        color: palette.background,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: context.navigator.pop,
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 21,
                              color: palette.ink,
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
          Expanded(
            flex: 10,
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: [
                    Text(
                      'Walk',
                      style: CleanTheme.largeTitle.copyWith(color: palette.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CleanTheme.dateAndTimeRange(route),
                      style: CleanTheme.body.copyWith(color: palette.muted),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        _StatCell(
                          label: 'DISTANCE',
                          value: route.distanceLabel,
                        ),
                        _StatCell(
                          label: 'DURATION',
                          value: route.durationLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StatCell(label: 'AVG PACE', value: _pace()),
                        _StatCell(label: 'PLACES', value: '${nearby.length}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: CleanTheme.hairline),
                    const SizedBox(height: 18),
                    Text(
                      'Places on this walk',
                      style: CleanTheme.headline.copyWith(color: palette.ink),
                    ),
                    const SizedBox(height: 6),
                    if (nearby.isEmpty)
                      Text(
                        'Press and hold the map to save a place.',
                        style: CleanTheme.footnote.copyWith(
                          color: palette.muted,
                          fontSize: 14,
                        ),
                      ),
                    for (final poi in nearby) _PlaceRow(poi: poi),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CleanTheme.micro.copyWith(color: CleanTheme.palette.muted),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: CleanTheme.stat.copyWith(color: CleanTheme.palette.ink),
        ),
      ],
    ),
  );
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.poi});

  final POI poi;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: CleanTheme.fill,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.place_rounded, color: CleanTheme.palette.primary),
    ),
    title: Text(
      poi.name,
      style: CleanTheme.headline.copyWith(color: CleanTheme.palette.ink),
    ),
    trailing: Icon(
      Icons.open_in_new_rounded,
      size: 18,
      color: CleanTheme.palette.muted,
    ),
    onTap: () => context.read<LaunchableMapsCubit>().launchMapAtPOI(poi),
  );
}

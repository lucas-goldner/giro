import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/widgets/adaptive_scaffold.dart';
import 'package:giro/map/widgets/poi_add_dialog.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage(this.passedRoute, {super.key});
  static const String routeName = '/route_detail';
  final WalkRoute passedRoute;

  @override
  Widget build(BuildContext context) => RouteDetail(passedRoute);
}

class RouteDetail extends StatelessWidget {
  const RouteDetail(this.route, {super.key});
  final WalkRoute route;

  void onLongPress({required LatLng location, required BuildContext context}) =>
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => PoiAddDialog(
          location: location,
          onAdd: (poi) {
            context.read<PoiCubit>().addPOI(poi);
            context.navigator.pop();
          },
          onCancel: context.navigator.pop,
        ),
      );

  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
        title: const Text('Routes Detail'),
        child: BlocBuilder<PoiCubit, PoiState>(
          buildWhen: (previous, current) => previous.pois != current.pois,
          builder: (context, poiState) => PlatformMap(
            initialCameraPosition: CameraPosition(
              target: route.coordinates.first,
              zoom: 16,
            ),
            polylines: {
              Polyline(
                polylineId: PolylineId('route_${route.id}'),
                color: Colors.red,
                width: 2,
                points: route.coordinates,
              ),
            },
            markers: poiState.pois
                .map(
                  (poi) => Marker(
                    markerId: MarkerId(poi.id),
                    position: poi.coordinates,
                    onTap: () =>
                        context.read<LaunchableMapsCubit>().launchMapAtPOI(poi),
                  ),
                )
                .toSet(),
            onLongPress: (location) => onLongPress(
              location: location,
              context: context,
            ),
          ),
        ),
      );
}

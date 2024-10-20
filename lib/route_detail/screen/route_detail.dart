import 'package:flutter/material.dart';
import 'package:giro/core/model/walk_route.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Routes Detail'),
        ),
        body: PlatformMap(
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
          // TODO: Add current location
          // myLocationEnabled: true,
          // myLocationButtonEnabled: true,
          onTap: (location) => print('onTap: $location'),
        ),
      );
}

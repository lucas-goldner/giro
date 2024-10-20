import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/map/cubit/healthkit_cubit.dart';
import 'package:giro/map/repository/healthkit_repo_method_channel_impl.dart';
import 'package:giro/map/screen/importer_dialog.dart';
import 'package:giro/map/widgets/draggable_sheet.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class GiroMapPage extends StatelessWidget {
  const GiroMapPage({super.key});
  static const String routeName = '/';

  MaterialPageRoute<void> get route => MaterialPageRoute(
        builder: (_) => this,
      );

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => HealthkitCubit(HealthkitRepoMethodChannelImpl()),
        child: const GiroMap(),
      );
}

class GiroMap extends StatelessWidget {
  const GiroMap({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            BlocBuilder<WalkRoutesCubit, WalkRoutesState>(
              builder: (context, state) {
                return PlatformMap(
                  initialCameraPosition: const CameraPosition(
                    // Tokyo
                    // target: LatLng(35.682839, 139.759455),
                    target: LatLng(48.962316599573725, 9.262961877486779),
                    zoom: 16,
                  ),
                  circles: state.routes
                      .map(
                        (route) => Circle(
                          circleId: CircleId(route.id),
                          center: LatLng(
                            route.coordinates[0].latitude,
                            route.coordinates[0].longitude,
                          ),
                          radius: 100,
                          fillColor: Colors.red.withOpacity(0.5),
                          strokeColor: Colors.red,
                          strokeWidth: 2,
                        ),
                      )
                      .toSet(),

                  //  <Circle>{
                  //   Circle(
                  //     circleId: CircleId('circle_1'),
                  //     center:
                  //         const LatLng(35.663185479303176, 139.70270127423208),
                  //     radius: 100,
                  //     fillColor: Colors.red.withOpacity(0.5),
                  //     strokeColor: Colors.red,
                  //     strokeWidth: 2,
                  //   ),
                  // },

                  // TODO: Add current location
                  // myLocationEnabled: true,
                  // myLocationButtonEnabled: true,
                  onTap: (location) => print('onTap: $location'),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableSheet(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Giro',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    child: const Text('Import last route'),
                    onPressed: () => showModalBottomSheet<void>(
                      useSafeArea: true,
                      builder: (_) => const ImporterDialogPage(),
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
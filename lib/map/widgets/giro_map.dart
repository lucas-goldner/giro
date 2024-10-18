import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/extensions.dart';
import 'package:giro/healthkit/cubit/healthkit_cubit.dart';
import 'package:giro/healthkit/repository/healthkit_repo_method_channel_impl.dart';
import 'package:giro/map/widgets/draggable_sheet.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class GiroMapPage extends StatelessWidget {
  const GiroMapPage({super.key});
  static const String routeName = "/";

  MaterialPageRoute get route => MaterialPageRoute(
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            PlatformMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(35.66318547930317, 139.70270127423208),
                zoom: 16.0,
              ),
              circles: <Circle>{
                Circle(
                  circleId: CircleId('circle_1'),
                  center: const LatLng(35.663185479303176, 139.70270127423208),
                  radius: 100,
                  fillColor: Colors.red.withOpacity(0.5),
                  strokeColor: Colors.red,
                  strokeWidth: 2,
                  visible: true,
                ),
              },
              // myLocationEnabled: true,
              // myLocationButtonEnabled: true,
              onTap: (location) => print('onTap: $location'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableSheet(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          "Giro",
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          context.read<HealthkitCubit>().isAuthorized
                              ? "Authorized"
                              : "Not authorized",
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    child: const Text("Get access"),
                    onPressed: () => context.read<HealthkitCubit>().authorize(),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    child: const Text("Import last route"),
                    onPressed: () => {
                      print(context.read<HealthkitCubit>().isAuthorized),
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

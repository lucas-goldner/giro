import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/extensions.dart';
import 'package:giro/map_menu.dart';
import 'package:giro/service/healthkit_impl.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool requested = false;
  final HealthKitImpl healthKit = HealthKitImpl();

  @override
  void initState() {
    healthKit.initialize();
    super.initState();
  }

  Future<void> _authorizeHealth() async {
    healthKit.requestHealthAccess();
    // setState(() {
    //   requested = true;
    // });
  }

  Future<void> _readData() async {
    print("Read Route");
    healthKit.retrieveLastWalkingWorkout();

    print("Fetched");
  }

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
                          requested ? "Authorized" : "Not authorized",
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
                    onPressed: () => _authorizeHealth(),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    child: const Text("Import last route"),
                    onPressed: () => _readData(),
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

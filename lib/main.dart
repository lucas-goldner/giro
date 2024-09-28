import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PlatformMap(
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
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (location) => print('onTap: $location'),
        ),
      ),
    );
  }
}

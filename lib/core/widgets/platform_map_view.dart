import 'package:flutter/widgets.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/web_mocks/mock_platform_map.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// The map used by every screen.
///
/// On iOS and Android this is the real [PlatformMap] (Apple Maps / Google
/// Maps). On the web, desktop and in widget tests, where those plugins do not
/// exist, it falls back to [MockPlatformMap], which draws the same markers and
/// polylines on a canvas so the UI around the map can still be exercised.
class PlatformMapView extends StatelessWidget {
  const PlatformMapView({
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.compassEnabled = true,
    this.onLongPress,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final void Function(LatLng)? onLongPress;

  @override
  Widget build(BuildContext context) => PlatformStyle.hasNativeMap
      ? PlatformMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          polylines: polylines,
          myLocationEnabled: myLocationEnabled,
          myLocationButtonEnabled: myLocationButtonEnabled,
          compassEnabled: compassEnabled,
          onLongPress: onLongPress,
        )
      : MockPlatformMap(
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          polylines: polylines,
          myLocationEnabled: myLocationEnabled,
          onLongPress: onLongPress,
        );
}

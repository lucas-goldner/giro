import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/core/widgets/web_google_map.dart';
import 'package:giro/web_mocks/mock_platform_map.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// The map used by every screen.
///
/// On iOS and Android this is the real [PlatformMap] (Apple Maps / Google
/// Maps). On the web it is [WebGoogleMap], the Google Maps JavaScript map.
/// Everywhere else (desktop, widget tests) and when
/// [PlatformStyle.forceMockMap] is set, it falls back to [MockPlatformMap],
/// which draws the same markers and polylines on a canvas.
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
  Widget build(BuildContext context) {
    if (PlatformStyle.hasNativeMap) {
      return PlatformMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: myLocationEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        onLongPress: onLongPress,
      );
    }
    if (kIsWeb && !PlatformStyle.forceMockMap) {
      return WebGoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: myLocationEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        onLongPress: onLongPress,
      );
    }
    return MockPlatformMap(
      initialCameraPosition: initialCameraPosition,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: myLocationEnabled,
      onLongPress: onLongPress,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/core/widgets/fog_of_war.dart';
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
///
/// With [fogOfWar] (the default) the map is covered in white and only
/// uncovered along the [polylines] and around the [markers]: the parts of
/// the city the user has actually walked.
class PlatformMapView extends StatefulWidget {
  const PlatformMapView({
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.compassEnabled = true,
    this.fogOfWar = true,
    this.onLongPress,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final bool fogOfWar;
  final void Function(LatLng)? onLongPress;

  @override
  State<PlatformMapView> createState() => _PlatformMapViewState();
}

class _PlatformMapViewState extends State<PlatformMapView> {
  late final ValueNotifier<CameraPosition> _camera = ValueNotifier(
    widget.initialCameraPosition,
  );
  var _cameraReported = false;

  @override
  void didUpdateWidget(PlatformMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Screens like "Record walk" only know a sensible target after the first
    // location sample; keep the fog aligned with it until the map itself
    // reports where it is looking.
    if (!_cameraReported &&
        widget.initialCameraPosition != oldWidget.initialCameraPosition) {
      _camera.value = widget.initialCameraPosition;
    }
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _cameraReported = true;
    _camera.value = position;
  }

  Widget _map() {
    if (PlatformStyle.hasNativeMap) {
      return PlatformMap(
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        polylines: widget.polylines,
        myLocationEnabled: widget.myLocationEnabled,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        compassEnabled: widget.compassEnabled,
        onLongPress: widget.onLongPress,
        onCameraMove: _onCameraMove,
      );
    }
    if (kIsWeb && !PlatformStyle.forceMockMap) {
      return WebGoogleMap(
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        polylines: widget.polylines,
        myLocationEnabled: widget.myLocationEnabled,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        compassEnabled: widget.compassEnabled,
        onLongPress: widget.onLongPress,
        onCameraMove: _onCameraMove,
      );
    }
    return MockPlatformMap(
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers,
      polylines: widget.polylines,
      myLocationEnabled: widget.myLocationEnabled,
      onLongPress: widget.onLongPress,
      onCameraMove: _onCameraMove,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fogOfWar) {
      return _map();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _map(),
        FogOfWar(
          camera: _camera,
          paths: [for (final polyline in widget.polylines) polyline.points],
          points: [for (final marker in widget.markers) marker.position],
        ),
      ],
    );
  }
}

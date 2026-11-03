import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';
import 'package:giro/core/platform_style.dart';
import 'package:giro/core/widgets/fog_of_war.dart';
import 'package:giro/core/widgets/maplibre_map_view_stub.dart'
    if (dart.library.ffi) 'package:giro/core/widgets/maplibre_map_view.dart';
import 'package:giro/core/widgets/web_maplibre_map_stub.dart'
    if (dart.library.js_interop) 'package:giro/core/widgets/web_maplibre_map.dart';
import 'package:giro/web_mocks/mock_platform_map.dart';

/// The map used by every screen.
///
/// On iOS and Android this is [MapLibreMapView]: MapLibre rendered with
/// Flutter GPU, with the fog of war and 3D buildings drawn inside the map's
/// own frame. On the web it is [WebMapLibreMap] (MapLibre GL JS, same style)
/// under a canvas [FogOfWar]. Everywhere else (desktop, widget tests) and
/// when [PlatformStyle.forceMockMap] is set, [MockPlatformMap] draws the
/// markers and polylines on a canvas, also under the canvas fog.
///
/// With [fogOfWar] (the default) the map is white and only uncovered along
/// the [polylines] and around the [markers]: the parts of the city the user
/// has actually walked.
class PlatformMapView extends StatefulWidget {
  const PlatformMapView({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.fogOfWar = true,
    this.onLongPress,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<MapMarker> markers;
  final Set<MapPolyline> polylines;
  final bool myLocationEnabled;
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
  final _mask = ValueNotifier<ExploredMask?>(null);
  var _cameraReported = false;
  var _maskGeneration = 0;

  bool get _usesCanvasFog => widget.fogOfWar && !PlatformStyle.hasNativeMap;

  @override
  void initState() {
    super.initState();
    if (_usesCanvasFog) {
      unawaited(_rebuildMask());
    }
  }

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
    if (_usesCanvasFog &&
        (!setEquals(widget.polylines, oldWidget.polylines) ||
            !setEquals(widget.markers, oldWidget.markers))) {
      unawaited(_rebuildMask());
    }
  }

  @override
  void dispose() {
    _camera.dispose();
    _mask.value?.dispose();
    _mask.dispose();
    super.dispose();
  }

  Future<void> _rebuildMask() async {
    final generation = ++_maskGeneration;
    final mask = await ExploredMask.build(
      paths: [for (final polyline in widget.polylines) polyline.points],
      points: [for (final marker in widget.markers) marker.position],
    );
    if (!mounted || generation != _maskGeneration) {
      mask?.dispose();
      return;
    }
    final previous = _mask.value;
    _mask.value = mask;
    previous?.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _cameraReported = true;
    _camera.value = position;
  }

  Widget _map() {
    if (PlatformStyle.hasNativeMap) {
      return MapLibreMapView(
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        polylines: widget.polylines,
        myLocationEnabled: widget.myLocationEnabled,
        compassEnabled: widget.compassEnabled,
        fogOfWar: widget.fogOfWar,
        onLongPress: widget.onLongPress,
        onCameraMove: _onCameraMove,
      );
    }
    if (kIsWeb && !PlatformStyle.forceMockMap) {
      return WebMapLibreMap(
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        polylines: widget.polylines,
        myLocationEnabled: widget.myLocationEnabled,
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
    if (!_usesCanvasFog) {
      return _map();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _map(),
        FogOfWar(camera: _camera, mask: _mask),
      ],
    );
  }
}

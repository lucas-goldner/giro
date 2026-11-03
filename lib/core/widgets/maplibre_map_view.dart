import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/map/explored_buildings.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/map/giro_map_style.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// The iOS/Android map: MapLibre rendered with Flutter GPU.
///
/// No platform view is involved, so the fog of war ([FogGpu]), the 3D
/// buildings ([ExploredBuildings]) and the spot markers are all drawn in the
/// same frame as the map. Walks are part of the style itself (see
/// [GiroMapStyle]); the style is reloaded when they change.
class MapLibreMapView extends StatefulWidget {
  const MapLibreMapView({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.fogOfWar = true,
    this.onLongPress,
    this.onCameraMove,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<MapMarker> markers;
  final Set<MapPolyline> polylines;
  final bool myLocationEnabled;
  final bool compassEnabled;
  final bool fogOfWar;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<MapLibreMapView> createState() => _MapLibreMapViewState();
}

class _MapLibreMapViewState extends State<MapLibreMapView> {
  ml.MapLibreMapController? _controller;
  Map<String, dynamic>? _template;
  String? _styleJson;
  final _fog = FogGpu();
  final _buildings = ExploredBuildings();
  ExploredMask? _mask;
  int _maskGeneration = 0;
  StreamSubscription<Position>? _locationSubscription;
  ml.MapUserLocation? _userLocation;
  bool _userMovedCamera = false;
  bool _animatingCamera = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStyle());
    unawaited(_fog.ensureLoaded());
    unawaited(_buildings.ensureLoaded());
    unawaited(_rebuildMask());
    _updateLocationStream();
  }

  @override
  void didUpdateWidget(MapLibreMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.polylines, oldWidget.polylines)) {
      unawaited(_applyStyle());
    }
    if (!setEquals(widget.polylines, oldWidget.polylines) ||
        !setEquals(widget.markers, oldWidget.markers)) {
      unawaited(_rebuildMask());
    }
    if (widget.myLocationEnabled != oldWidget.myLocationEnabled) {
      _updateLocationStream();
    }
    // Screens like "Record walk" move the camera by handing in a new initial
    // position; follow it until the user takes over.
    if (!_userMovedCamera &&
        widget.initialCameraPosition != oldWidget.initialCameraPosition) {
      unawaited(_follow(widget.initialCameraPosition));
    }
  }

  @override
  void dispose() {
    unawaited(_locationSubscription?.cancel());
    _fog.dispose();
    _buildings.dispose();
    _mask?.dispose();
    super.dispose();
  }

  Future<void> _loadStyle() async {
    _template = await GiroMapStyle.template();
    await _applyStyle();
  }

  Future<void> _applyStyle() async {
    final template = _template;
    if (template == null) {
      return;
    }
    final json = GiroMapStyle.encode(template, widget.polylines);
    if (json == _styleJson || !mounted) {
      return;
    }
    // MapLibreMap reloads the style itself when styleString changes.
    setState(() => _styleJson = json);
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
    _mask?.dispose();
    _mask = mask;
    _buildings.setMask(mask);
    await _fog.setMask(mask);
  }

  void _updateLocationStream() {
    unawaited(_locationSubscription?.cancel());
    _locationSubscription = null;
    if (!widget.myLocationEnabled) {
      setState(() => _userLocation = null);
      return;
    }
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(distanceFilter: 2),
        ).listen((position) {
          if (!mounted) {
            return;
          }
          setState(
            () => _userLocation = ml.MapUserLocation(
              position: ml.LatLng(position.latitude, position.longitude),
              headingDegrees: position.heading.isFinite && position.heading >= 0
                  ? position.heading
                  : null,
              accuracyMeters: position.accuracy.isFinite
                  ? position.accuracy
                  : null,
            ),
          );
        }, onError: (Object _) {});
  }

  Future<void> _follow(CameraPosition camera) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _animatingCamera = true;
    try {
      await controller.animateCamera(
        ml.CameraUpdate.newLatLngZoom(_toMl(camera.target), camera.zoom),
        duration: const Duration(milliseconds: 400),
      );
    } finally {
      _animatingCamera = false;
    }
  }

  void _onCameraMove(ml.CameraPosition camera) {
    if (!_animatingCamera) {
      _userMovedCamera = true;
    }
    widget.onCameraMove?.call(
      CameraPosition(
        target: LatLng(camera.target.latitude, camera.target.longitude),
        zoom: camera.zoom,
        bearing: camera.bearing,
        tilt: camera.tilt,
      ),
    );
  }

  static ml.LatLng _toMl(LatLng point) =>
      ml.LatLng(point.latitude, point.longitude);

  Widget? _markerOverlay(BuildContext context, ml.MapFrameState frame) {
    final controller = _controller;
    if (controller == null || widget.markers.isEmpty) {
      return null;
    }
    const size = 26.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final marker in widget.markers)
          for (final offset in controller.toScreenOffsets(
            _toMl(marker.position),
            padding: const EdgeInsets.all(size),
          ))
            Positioned(
              left: offset.dx - size / 2,
              top: offset.dy - size / 2,
              width: size,
              height: size,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: marker.onTap,
                child: Semantics(
                  button: marker.onTap != null,
                  label: 'Spot',
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SonicTheme.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(child: SonicSpotIcon(size: 18)),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleJson;
    if (style == null) {
      return const ColoredBox(color: SonicTheme.white);
    }
    final camera = widget.initialCameraPosition;
    return ml.MapLibreMap(
      styleString: style,
      initialCameraPosition: ml.CameraPosition(
        target: _toMl(camera.target),
        zoom: camera.zoom,
        bearing: camera.bearing,
        tilt: camera.tilt,
      ),
      onMapCreated: (controller) => _controller = controller,
      onCameraMove: _onCameraMove,
      onMapLongClick: widget.onLongPress == null
          ? null
          : (_, coordinates) => widget.onLongPress!(
              LatLng(coordinates.latitude, coordinates.longitude),
            ),
      compassEnabled: widget.compassEnabled,
      overlayBuilder: _markerOverlay,
      userLocation: _userLocation,
      gpuRenderCallback: widget.fogOfWar ? _fog.render : null,
      gpuRepaint: _fog.repaint,
      gpuOverlayReadsMapColor: widget.fogOfWar,
      fillExtrusionRendererBuilder: widget.fogOfWar
          ? (layer) => ExploredBuildings.layerIds.contains(layer.id)
                ? _buildings
                : null
          : null,
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/map/giro_map_style.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// The iOS/Android map: MapLibre rendered with Flutter GPU.
///
/// No platform view is involved, so the fog of war ([FogGpu]) and the spot
/// markers are drawn in the same frame as the map. The 3D buildings layer
/// is shown only while the map is tilted; flat on top is the clean look.
/// Walks are part of the style itself (see [GiroMapStyle]); the style is
/// reloaded when they change.
class MapLibreMapView extends StatefulWidget {
  const MapLibreMapView({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.fogOfWar = true,
    this.revealRadiusMeters = 90,
    this.pointRadiusMeters = 72,
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
  final double revealRadiusMeters;
  final double pointRadiusMeters;
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
  ExploredMask? _mask;
  int _maskGeneration = 0;
  StreamSubscription<Position>? _locationSubscription;
  ml.MapUserLocation? _userLocation;
  bool _userMovedCamera = false;
  bool _animatingCamera = false;
  bool _idleOnce = false;
  String? _tileUrlTemplate;
  String? _localBaseUrl;
  bool _styleLoaded = false;
  bool? _buildingsShown;
  Timer? _loadingTimeout;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStyle());
    unawaited(_fog.ensureLoaded());
    unawaited(_rebuildMask());
    _updateLocationStream();
    // The idle callback is the real signal; this is the safety net.
    _loadingTimeout = Timer(const Duration(seconds: 8), _hideLoading);
  }

  void _hideLoading() {
    _loadingTimeout?.cancel();
    if (!_idleOnce && mounted) {
      setState(() => _idleOnce = true);
    }
  }

  /// 3D buildings only while the map is tilted; flat buildings otherwise.
  void _syncBuildings(double tilt) {
    final controller = _controller;
    final show = tilt > 3;
    if (controller == null || !_styleLoaded || show == _buildingsShown) {
      return;
    }
    _buildingsShown = show;
    unawaited(
      controller
          .setLayerVisibility(GiroMapStyle.buildings3dLayer, show)
          .catchError((Object _) {}),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The on-device tile cache (null on platforms without one).
    final store = context.read<TileStore?>();
    final template = store?.tileUrlTemplate;
    final base = store?.localBaseUrl;
    if (template != _tileUrlTemplate || base != _localBaseUrl) {
      _tileUrlTemplate = template;
      _localBaseUrl = base;
      unawaited(_applyStyle());
    }
  }

  @override
  void didUpdateWidget(MapLibreMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.polylines, oldWidget.polylines)) {
      unawaited(_applyStyle());
    }
    if (!setEquals(widget.polylines, oldWidget.polylines) ||
        !setEquals(widget.markers, oldWidget.markers) ||
        widget.revealRadiusMeters != oldWidget.revealRadiusMeters ||
        widget.pointRadiusMeters != oldWidget.pointRadiusMeters) {
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
    _loadingTimeout?.cancel();
    unawaited(_locationSubscription?.cancel());
    _fog.dispose();
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
    final json = GiroMapStyle.encode(
      template,
      widget.polylines,
      tileUrlTemplate: _tileUrlTemplate,
      localBaseUrl: _localBaseUrl,
    );
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
      revealRadiusMeters: widget.revealRadiusMeters,
      pointRadiusMeters: widget.pointRadiusMeters,
    );
    if (!mounted || generation != _maskGeneration) {
      mask?.dispose();
      return;
    }
    _mask?.dispose();
    _mask = mask;
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
    _syncBuildings(camera.tilt);
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
    // Below the status bar and the HUD chips, not under them.
    final compassTop = MediaQuery.paddingOf(context).top + 64;
    return Stack(
      fit: StackFit.expand,
      children: [
        ml.MapLibreMap(
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
          compassViewPosition: ml.CompassViewPosition.topRight,
          compassViewMargins: math.Point<num>(14, compassTop),
          attributionButtonMargins: const math.Point<num>(10, 10),
          onStyleLoadedCallback: () {
            _styleLoaded = true;

            _buildingsShown = null;

            _syncBuildings(_controller?.frameState?.camera.tilt ?? 0);
          },

          onMapIdle: _hideLoading,
          overlayBuilder: _markerOverlay,
          userLocation: _userLocation,
          gpuRenderCallback: widget.fogOfWar ? _fog.render : null,
          gpuRepaint: _fog.repaint,
          gpuOverlayReadsMapColor: widget.fogOfWar,
        ),
        if (!_idleOnce)
          Positioned(
            right: 16,
            bottom: 16,
            child: IgnorePointer(
              child: Semantics(
                label: 'Loading map',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: SonicTheme.navy.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SonicTheme.gold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'LOADING MAP',
                        style: TextStyle(
                          fontFamily: SonicTheme.font,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1,
                          color: SonicTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

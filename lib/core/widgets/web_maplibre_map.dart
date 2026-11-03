import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:giro/core/map/giro_map_style.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/model/map_overlay.dart';
import 'package:web/web.dart' as web;

/// The web preview map: MapLibre GL JS (loaded in `web/index.html`) showing
/// the same Sonic style and walk layers as the iOS app.
///
/// It is a platform view, so the fog of war is drawn by the canvas
/// `FogOfWar` overlay on top, re-projected from the camera reported here on
/// every `move` event.
class WebMapLibreMap extends StatefulWidget {
  const WebMapLibreMap({
    required this.initialCameraPosition,
    this.markers = const <MapMarker>{},
    this.polylines = const <MapPolyline>{},
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.onLongPress,
    this.onCameraMove,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<MapMarker> markers;
  final Set<MapPolyline> polylines;
  final bool myLocationEnabled;
  final bool compassEnabled;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<WebMapLibreMap> createState() => _WebMapLibreMapState();
}

class _WebMapLibreMapState extends State<WebMapLibreMap> {
  static int _instances = 0;

  late final String _viewType = 'giro-maplibre-${_instances++}';
  late final web.HTMLDivElement _container;
  _JsMap? _map;
  Map<String, dynamic>? _template;
  String? _styleJson;
  final _markers = <String, _JsMarker>{};
  _JsMarker? _location;
  bool _userMovedCamera = false;
  bool _viewCreated = false;

  @override
  void initState() {
    super.initState();
    _container = web.document.createElement('div') as web.HTMLDivElement;
    _container.style
      ..width = '100%'
      ..height = '100%';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _container,
    );
    unawaited(_loadStyle());
  }

  @override
  void didUpdateWidget(WebMapLibreMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(widget.polylines, oldWidget.polylines)) {
      _applyStyle();
    }
    if (!setEquals(widget.markers, oldWidget.markers)) {
      _syncMarkers();
    }
    if (!_userMovedCamera &&
        widget.initialCameraPosition.target !=
            oldWidget.initialCameraPosition.target) {
      _map?.jumpTo(
        {
              'center': [
                widget.initialCameraPosition.target.longitude,
                widget.initialCameraPosition.target.latitude,
              ],
              'zoom': widget.initialCameraPosition.zoom,
            }.jsify()!
            as JSObject,
      );
    }
    if (widget.myLocationEnabled != oldWidget.myLocationEnabled ||
        widget.initialCameraPosition.target !=
            oldWidget.initialCameraPosition.target) {
      _syncLocation();
    }
  }

  @override
  void dispose() {
    for (final marker in _markers.values) {
      marker.remove();
    }
    _location?.remove();
    _map?.remove();
    super.dispose();
  }

  Future<void> _loadStyle() async {
    _template = await GiroMapStyle.template();
    _applyStyle();
  }

  void _applyStyle() {
    final template = _template;
    if (template == null) {
      return;
    }
    final json = GiroMapStyle.encode(template, widget.polylines);
    if (json == _styleJson) {
      return;
    }
    _styleJson = json;
    final map = _map;
    if (map != null) {
      map.setStyle(_jsonParse(json));
    } else if (_viewCreated) {
      // The platform view was attached before the style had loaded.
      _createMap();
    }
  }

  void _createMap() {
    final style = _styleJson;
    if (_map != null || style == null) {
      return;
    }
    final camera = widget.initialCameraPosition;
    final map = _JsMap(
      {
            'container': _container,
            'style': _jsonParse(style),
            'center': [camera.target.longitude, camera.target.latitude],
            'zoom': camera.zoom,
            'bearing': camera.bearing,
            'pitch': camera.tilt,
            'attributionControl': {'compact': true},
            'dragRotate': false,
            'pitchWithRotate': false,
          }.jsify()!
          as JSObject,
    );
    _map = map;
    map
      ..on('move', _reportCamera.toJS)
      ..on('dragstart', (() => _userMovedCamera = true).toJS)
      ..on('wheel', (() => _userMovedCamera = true).toJS)
      ..on(
        'contextmenu',
        ((_JsMapMouseEvent event) {
          final lngLat = event.lngLat;
          widget.onLongPress?.call(LatLng(lngLat.lat, lngLat.lng));
        }).toJS,
      );
    _syncMarkers();
    _syncLocation();
    _reportCamera();
    // The platform view may be laid out after the map measured its container.
    Future<void>.delayed(
      const Duration(milliseconds: 50),
      // Interop members cannot be torn off.
      // ignore: unnecessary_lambdas
      () => map.resize(),
    );
  }

  void _reportCamera() {
    final map = _map;
    if (map == null) {
      return;
    }
    final centre = map.getCenter();
    widget.onCameraMove?.call(
      CameraPosition(
        target: LatLng(centre.lat, centre.lng),
        zoom: map.getZoom(),
        bearing: map.getBearing(),
        tilt: map.getPitch(),
      ),
    );
  }

  void _syncMarkers() {
    final map = _map;
    if (map == null) {
      return;
    }
    final wanted = {for (final marker in widget.markers) marker.id: marker};
    for (final id in _markers.keys.toList()) {
      if (!wanted.containsKey(id)) {
        _markers.remove(id)!.remove();
      }
    }
    for (final marker in wanted.values) {
      final existing = _markers[marker.id];
      if (existing != null) {
        existing.setLngLat(
          [marker.position.longitude, marker.position.latitude].jsify()!
              as JSArray<JSNumber>,
        );
        continue;
      }
      final element = web.document.createElement('div') as web.HTMLDivElement;
      element.style.cssText =
          'width: 26px; height: 26px; border-radius: 50%; background: #fff; '
          'box-shadow: 0 2px 4px rgba(0,0,0,.25); display: flex; '
          'align-items: center; justify-content: center; cursor: pointer;';
      final ring = web.document.createElement('div') as web.HTMLDivElement;
      ring.style.cssText =
          'width: 18px; height: 18px; border-radius: 50%; '
          'border: 4px solid #FFC400; box-sizing: border-box;';
      element
        ..appendChild(ring)
        ..setAttribute('aria-label', 'Spot')
        ..setAttribute('role', 'button')
        ..onclick = ((web.Event _) => marker.onTap?.call()).toJS;
      _markers[marker.id] = _JsMarker({'element': element}.jsify()! as JSObject)
          .setLngLat(
            [marker.position.longitude, marker.position.latitude].jsify()!
                as JSArray<JSNumber>,
          )
          .addTo(map);
    }
  }

  void _syncLocation() {
    final map = _map;
    if (map == null) {
      return;
    }
    if (!widget.myLocationEnabled) {
      _location?.remove();
      _location = null;
      return;
    }
    final target = widget.initialCameraPosition.target;
    final lngLat =
        [target.longitude, target.latitude].jsify()! as JSArray<JSNumber>;
    if (_location != null) {
      _location!.setLngLat(lngLat);
      return;
    }
    final element = web.document.createElement('div') as web.HTMLDivElement;
    element.style.cssText =
        'width: 18px; height: 18px; border-radius: 50%; background: #1B5BFF; '
        'border: 3px solid #fff; box-shadow: 0 0 0 6px rgba(27,91,255,.25);';
    _location = _JsMarker({'element': element}.jsify()! as JSObject)
        .setLngLat(lngLat)
        .addTo(map);
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(
    viewType: _viewType,
    onPlatformViewCreated: (_) =>
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _viewCreated = true;
          _createMap();
        }),
  );
}

@JS('JSON.parse')
external JSObject _jsonParse(String json);

@JS('maplibregl.Map')
extension type _JsMap._(JSObject _) implements JSObject {
  external _JsMap(JSObject options);
  external void on(String event, JSFunction listener);
  external _JsLngLat getCenter();
  external double getZoom();
  external double getBearing();
  external double getPitch();
  external void setStyle(JSObject style);
  external void jumpTo(JSObject options);
  external void resize();
  external void remove();
}

@JS('maplibregl.Marker')
extension type _JsMarker._(JSObject _) implements JSObject {
  external _JsMarker(JSObject options);
  external _JsMarker setLngLat(JSArray<JSNumber> lngLat);
  external _JsMarker addTo(_JsMap map);
  external void remove();
}

extension type _JsLngLat._(JSObject _) implements JSObject {
  external double get lng;
  external double get lat;
}

extension type _JsMapMouseEvent._(JSObject _) implements JSObject {
  external _JsLngLat get lngLat;
}

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// A stand-in for [PlatformMap] on platforms without Apple/Google Maps.
///
/// It draws a street-like grid in Web Mercator projection plus the given
/// [polylines] and [markers], supports drag-to-pan, pinch/scroll zoom, marker
/// taps and long presses (used to add points of interest). It follows
/// [initialCameraPosition] updates until the user pans, which keeps the
/// recording screen centred on the simulated walk.
class MockPlatformMap extends StatefulWidget {
  const MockPlatformMap({
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.myLocationEnabled = false,
    this.onLongPress,
    this.onCameraMove,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<MockPlatformMap> createState() => _MockPlatformMapState();
}

class _MockPlatformMapState extends State<MockPlatformMap> {
  static const _tileSize = 256.0;
  static const _markerHitRadius = 24.0;

  late LatLng _center = widget.initialCameraPosition.target;
  late double _zoom = widget.initialCameraPosition.zoom;
  double _zoomAtScaleStart = 16;
  bool _userMovedCamera = false;

  @override
  void didUpdateWidget(MockPlatformMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.initialCameraPosition.target;
    if (!_userMovedCamera &&
        target != oldWidget.initialCameraPosition.target &&
        target != const LatLng(0, 0)) {
      _center = target;
      _zoom = widget.initialCameraPosition.zoom;
      _reportCamera();
    }
  }

  void _reportCamera() => WidgetsBinding.instance.addPostFrameCallback(
    (_) =>
        widget.onCameraMove?.call(CameraPosition(target: _center, zoom: _zoom)),
  );

  double get _worldSize => _tileSize * math.pow(2, _zoom);

  Offset _project(LatLng latLng) {
    final sinLat = math
        .sin(latLng.latitude * math.pi / 180)
        .clamp(-0.9999, 0.9999);
    final x = (latLng.longitude + 180) / 360 * _worldSize;
    final y =
        (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) *
        _worldSize;
    return Offset(x, y);
  }

  LatLng _unproject(Offset world) {
    final longitude = world.dx / _worldSize * 360 - 180;
    final n = math.pi - 2 * math.pi * world.dy / _worldSize;
    final latitude =
        180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
    return LatLng(latitude, longitude);
  }

  Offset _toScreen(LatLng latLng, Size size) =>
      _project(latLng) - _project(_center) + size.center(Offset.zero);

  LatLng _fromScreen(Offset local, Size size) =>
      _unproject(local - size.center(Offset.zero) + _project(_center));

  void _onScaleStart(ScaleStartDetails details) {
    _zoomAtScaleStart = _zoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _userMovedCamera = true;
      _zoom = (_zoomAtScaleStart + math.log(details.scale) / math.ln2).clamp(
        2.0,
        20.0,
      );
      final centerWorld = _project(_center) - details.focalPointDelta;
      _center = _unproject(centerWorld);
    });
    _reportCamera();
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        _userMovedCamera = true;
        _zoom = (_zoom - event.scrollDelta.dy / 300).clamp(2.0, 20.0);
      });
      _reportCamera();
    }
  }

  void _onTapUp(TapUpDetails details, Size size) {
    for (final marker in widget.markers) {
      final distance =
          (_toScreen(marker.position, size) - details.localPosition).distance;
      if (distance <= _markerHitRadius) {
        marker.onTap?.call();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      return Listener(
        onPointerSignal: _onPointerSignal,
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onTapUp: (details) => _onTapUp(details, size),
          onLongPressStart: widget.onLongPress == null
              ? null
              : (details) => widget.onLongPress!(
                  _fromScreen(details.localPosition, size),
                ),
          child: Semantics(
            label: 'Mock map',
            child: CustomPaint(
              size: size,
              painter: _MockMapPainter(
                center: _center,
                zoom: _zoom,
                markers: widget.markers,
                polylines: widget.polylines,
                myLocation: widget.myLocationEnabled
                    ? widget.initialCameraPosition.target
                    : null,
                project: (latLng) => _toScreen(latLng, size),
                worldOffset: _project(_center) - size.center(Offset.zero),
                colorScheme: Theme.of(context).colorScheme,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Mock map · zoom ${_zoom.toStringAsFixed(1)} · '
                        '${_center.latitude.toStringAsFixed(4)}, '
                        '${_center.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _MockMapPainter extends CustomPainter {
  _MockMapPainter({
    required this.center,
    required this.zoom,
    required this.markers,
    required this.polylines,
    required this.myLocation,
    required this.project,
    required this.worldOffset,
    required this.colorScheme,
  });

  final LatLng center;
  final double zoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng? myLocation;
  final Offset Function(LatLng) project;
  final Offset worldOffset;
  final ColorScheme colorScheme;

  static const _land = Color(0xFFEDEAE2);
  static const _minorStreet = Color(0xFFFFFFFF);
  static const _majorStreet = Color(0xFFF8D97A);
  static const _park = Color(0xFFCDE6C5);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _land);
    _paintBlocks(canvas, size);
    _paintStreets(canvas, size);

    for (final polyline in polylines) {
      if (polyline.points.length < 2) {
        continue;
      }
      final path = Path()..moveTo(0, 0);
      final first = project(polyline.points.first);
      path
        ..reset()
        ..moveTo(first.dx, first.dy);
      for (final point in polyline.points.skip(1)) {
        final offset = project(point);
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = polyline.color
          ..strokeWidth = polyline.width.toDouble() + 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (myLocation != null) {
      final offset = project(myLocation!);
      canvas
        ..drawCircle(
          offset,
          14,
          Paint()..color = Colors.blue.withValues(alpha: 0.2),
        )
        ..drawCircle(offset, 7, Paint()..color = Colors.white)
        ..drawCircle(offset, 5, Paint()..color = Colors.blue);
    }

    for (final marker in markers) {
      _paintPin(canvas, project(marker.position));
    }
  }

  /// Fake city blocks: a deterministic pattern of parks keyed by world tile
  /// coordinates so they stay put while panning.
  void _paintBlocks(Canvas canvas, Size size) {
    final block = 96.0 * math.pow(2, zoom - 16);
    if (block < 12) {
      return;
    }
    final startX = (worldOffset.dx / block).floor();
    final startY = (worldOffset.dy / block).floor();
    final columns = (size.width / block).ceil() + 1;
    final rows = (size.height / block).ceil() + 1;
    final paint = Paint()..color = _park;
    for (var i = 0; i <= columns; i++) {
      for (var j = 0; j <= rows; j++) {
        final tileX = startX + i;
        final tileY = startY + j;
        if ((tileX * 7 + tileY * 13) % 9 != 0) {
          continue;
        }
        final rect = Rect.fromLTWH(
          tileX * block - worldOffset.dx + 6,
          tileY * block - worldOffset.dy + 6,
          block - 12,
          block - 12,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          paint,
        );
      }
    }
  }

  void _paintStreets(Canvas canvas, Size size) {
    final block = 96.0 * math.pow(2, zoom - 16);
    if (block < 12) {
      return;
    }
    final minor = Paint()
      ..color = _minorStreet
      ..strokeWidth = 3;
    final major = Paint()
      ..color = _majorStreet
      ..strokeWidth = 6;
    final firstX = (worldOffset.dx / block).floor();
    for (var x = firstX; x * block - worldOffset.dx < size.width; x++) {
      final dx = x * block - worldOffset.dx;
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, size.height),
        x % 4 == 0 ? major : minor,
      );
    }
    final firstY = (worldOffset.dy / block).floor();
    for (var y = firstY; y * block - worldOffset.dy < size.height; y++) {
      final dy = y * block - worldOffset.dy;
      canvas.drawLine(
        Offset(0, dy),
        Offset(size.width, dy),
        y % 4 == 0 ? major : minor,
      );
    }
  }

  void _paintPin(Canvas canvas, Offset tip) {
    const radius = 9.0;
    final head = tip - const Offset(0, 22);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(head.dx - radius * 0.85, head.dy + radius * 0.4)
      ..arcToPoint(
        Offset(head.dx + radius * 0.85, head.dy + radius * 0.4),
        radius: const Radius.circular(radius),
      )
      ..close();
    canvas
      ..drawPath(
        path.shift(const Offset(1, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.25),
      )
      ..drawPath(path, Paint()..color = const Color(0xFFE53935))
      ..drawCircle(head, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_MockMapPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.zoom != zoom ||
      oldDelegate.markers != markers ||
      oldDelegate.polylines != polylines ||
      oldDelegate.myLocation != myLocation;
}

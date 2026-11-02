import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Covers the map in white and reveals it only where the user has walked.
///
/// Sits on top of the (native, web or mock) map, ignores pointer events so
/// gestures still reach the map, and re-projects the revealed paths with
/// every camera move it is told about. Reveals are soft-edged strokes along
/// each path plus small discs around points, sized in metres so they stay
/// consistent across zoom levels.
class FogOfWar extends StatelessWidget {
  const FogOfWar({
    required this.camera,
    required this.paths,
    this.points = const [],
    this.revealRadiusMeters = 55,
    this.pointRadiusMeters = 45,
    this.fogColor = const Color(0xFFFFFFFF),
    this.fogOpacity = 0.97,
    super.key,
  });

  /// Current camera of the underlying map (centre + zoom, no bearing/tilt).
  final ValueListenable<CameraPosition> camera;

  /// Walked routes: everything within [revealRadiusMeters] is uncovered.
  final List<List<LatLng>> paths;

  /// Saved places: a disc of [pointRadiusMeters] is uncovered around each.
  final List<LatLng> points;

  final double revealRadiusMeters;
  final double pointRadiusMeters;
  final Color fogColor;
  final double fogOpacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ValueListenableBuilder<CameraPosition>(
      valueListenable: camera,
      builder: (context, position, _) => CustomPaint(
        painter: _FogPainter(
          camera: position,
          paths: paths,
          points: points,
          revealRadiusMeters: revealRadiusMeters,
          pointRadiusMeters: pointRadiusMeters,
          fog: fogColor.withValues(alpha: fogOpacity),
        ),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _FogPainter extends CustomPainter {
  _FogPainter({
    required this.camera,
    required this.paths,
    required this.points,
    required this.revealRadiusMeters,
    required this.pointRadiusMeters,
    required this.fog,
  });

  final CameraPosition camera;
  final List<List<LatLng>> paths;
  final List<LatLng> points;
  final double revealRadiusMeters;
  final double pointRadiusMeters;
  final Color fog;

  static const _tileSize = 256.0;

  double get _worldSize => _tileSize * math.pow(2, camera.zoom);

  Offset _project(LatLng latLng) {
    final sinLat = math
        .sin(latLng.latitude * math.pi / 180)
        .clamp(-0.9999, 0.9999);
    return Offset(
      (latLng.longitude + 180) / 360 * _worldSize,
      (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) *
          _worldSize,
    );
  }

  /// Web Mercator ground resolution at the camera's latitude.
  double get _metersPerPixel =>
      156543.03392 *
      math.cos(camera.target.latitude * math.pi / 180) /
      math.pow(2, camera.zoom);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final origin = _project(camera.target) - size.center(Offset.zero);
    Offset toScreen(LatLng latLng) => _project(latLng) - origin;

    final pathWidth = (2 * revealRadiusMeters / _metersPerPixel).clamp(
      6.0,
      4000.0,
    );
    final pointRadius = (pointRadiusMeters / _metersPerPixel).clamp(
      4.0,
      2000.0,
    );
    final feather = (pathWidth * 0.35).clamp(2.0, 60.0);

    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(rect, Paint()..color = fog);

    // Everything drawn with dstOut erases the fog; the blur feathers the
    // edge so the reveal looks like a glow rather than a hard cut-out.
    final eraser = Paint()
      ..color = Colors.black
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.stroke
      ..strokeWidth = pathWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, feather);
    final pointEraser = Paint()
      ..color = Colors.black
      ..blendMode = BlendMode.dstOut
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, feather);

    for (final path in paths) {
      if (path.isEmpty) {
        continue;
      }
      if (path.length == 1) {
        canvas.drawCircle(toScreen(path.first), pathWidth / 2, pointEraser);
        continue;
      }
      final screenPath = Path();
      final first = toScreen(path.first);
      screenPath.moveTo(first.dx, first.dy);
      for (final latLng in path.skip(1)) {
        final offset = toScreen(latLng);
        screenPath.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(screenPath, eraser);
    }
    for (final point in points) {
      canvas.drawCircle(toScreen(point), pointRadius, pointEraser);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FogPainter oldDelegate) =>
      oldDelegate.camera != camera ||
      oldDelegate.paths != paths ||
      oldDelegate.points != points ||
      oldDelegate.fog != fog;
}

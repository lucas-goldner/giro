import 'package:flutter/material.dart';
import 'package:giro/core/model/geo.dart';

/// A small, map-free sketch of a walk: the route scaled into the box with a
/// start and end dot. Used as list thumbnails by every redesign.
///
/// The path is built once per size and the widget is its own repaint
/// boundary, so a list of these scrolls without re-projecting every walk
/// on every frame. Long walks are thinned to [maxPoints] first; at
/// thumbnail size the difference is invisible.
class RoutePreview extends StatelessWidget {
  const RoutePreview({
    required this.points,
    required this.color,
    this.background,
    this.strokeWidth = 3,
    this.maxPoints = 160,
    super.key,
  });

  final List<LatLng> points;
  final Color color;
  final Color? background;
  final double strokeWidth;
  final int maxPoints;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _RoutePreviewPainter(
        points: _thin(points, maxPoints),
        color: color,
        background: background,
        strokeWidth: strokeWidth,
      ),
      child: const SizedBox.expand(),
    ),
  );

  static List<LatLng> _thin(List<LatLng> points, int maxPoints) {
    if (points.length <= maxPoints) {
      return points;
    }
    final step = points.length / maxPoints;
    return [
      for (var i = 0; i < maxPoints - 1; i++) points[(i * step).floor()],
      points.last,
    ];
  }
}

class _RoutePreviewPainter extends CustomPainter {
  _RoutePreviewPainter({
    required this.points,
    required this.color,
    required this.background,
    required this.strokeWidth,
  });

  final List<LatLng> points;
  final Color color;
  final Color? background;
  final double strokeWidth;

  Size? _pathSize;
  Path? _path;
  late Offset _first;
  late Offset _last;

  void _buildPath(Size size) {
    if (_path != null && _pathSize == size) {
      return;
    }
    var minLat = points.first.latitude;
    var maxLat = minLat;
    var minLng = points.first.longitude;
    var maxLng = minLng;
    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    const inset = 10.0;
    final spanLat = (maxLat - minLat).clamp(1e-6, double.infinity);
    final spanLng = (maxLng - minLng).clamp(1e-6, double.infinity);
    final scale = ((size.width - 2 * inset) / spanLng)
        .clamp(0, (size.height - 2 * inset) / spanLat)
        .toDouble();
    final left = (size.width - spanLng * scale) / 2;
    final top = (size.height - spanLat * scale) / 2;

    Offset project(LatLng point) => Offset(
      left + (point.longitude - minLng) * scale,
      top + (maxLat - point.latitude) * scale,
    );

    final path = Path();
    final first = project(points.first);
    path.moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final offset = project(point);
      path.lineTo(offset.dx, offset.dy);
    }
    _path = path;
    _pathSize = size;
    _first = first;
    _last = project(points.last);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (background != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = background!);
    }
    if (points.length < 2) {
      return;
    }
    _buildPath(size);
    canvas
      ..drawPath(
        _path!,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawCircle(_first, strokeWidth + 1, Paint()..color = color)
      ..drawCircle(_last, strokeWidth + 2, Paint()..color = color)
      ..drawCircle(
        _last,
        strokeWidth,
        Paint()..color = background ?? Colors.white,
      );
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.background != background ||
      oldDelegate.strokeWidth != strokeWidth;
}

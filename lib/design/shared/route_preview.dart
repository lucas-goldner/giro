import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// A small, map-free sketch of a walk: the route scaled into the box with a
/// start and end dot. Used as list thumbnails by every redesign.
class RoutePreview extends StatelessWidget {
  const RoutePreview({
    required this.points,
    required this.color,
    this.background,
    this.strokeWidth = 3,
    super.key,
  });

  final List<LatLng> points;
  final Color color;
  final Color? background;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RoutePreviewPainter(
      points: points,
      color: color,
      background: background,
      strokeWidth: strokeWidth,
    ),
    child: const SizedBox.expand(),
  );
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

  @override
  void paint(Canvas canvas, Size size) {
    if (background != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = background!);
    }
    if (points.length < 2) {
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
    final drawnWidth = spanLng * scale;
    final drawnHeight = spanLat * scale;
    final left = (size.width - drawnWidth) / 2;
    final top = (size.height - drawnHeight) / 2;

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
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawCircle(first, strokeWidth + 1, Paint()..color = color)
      ..drawCircle(
        project(points.last),
        strokeWidth + 2,
        Paint()..color = color,
      )
      ..drawCircle(
        project(points.last),
        strokeWidth,
        Paint()..color = background ?? Colors.white,
      );
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.background != background;
}

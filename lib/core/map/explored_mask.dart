import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:giro/core/model/geo.dart';

/// Where the user has been, rasterised once in Web Mercator space.
///
/// White (opaque) texels are explored. The image covers the bounding box of
/// all paths and points plus a margin, at roughly `targetTexelMeters` per
/// texel, capped at `maxSize` texels per side. It is rebuilt only when walks
/// or spots change, never per frame: the fog of war overlays sample it with
/// one image draw (canvas backends) or one textured quad (Flutter GPU).
class ExploredMask {
  ExploredMask._({
    required this.image,
    required this.alpha,
    required this.width,
    required this.height,
    required this.u0,
    required this.v0,
    required this.u1,
    required this.v1,
  });

  /// Soft-edged reveal, white on transparent.
  final ui.Image image;

  /// The alpha channel of [image], row-major, for CPU lookups.
  final Uint8List alpha;
  final int width;
  final int height;

  /// Covered area in normalised Mercator coordinates (0..1 across the world,
  /// v growing south), matching MapLibre's world-pixel space divided by its
  /// world size.
  final double u0;
  final double v0;
  final double u1;
  final double v1;

  double get spanU => u1 - u0;
  double get spanV => v1 - v0;

  static const _earthCircumference = 40075016.686;

  static double mercatorU(double longitude) => (longitude + 180) / 360;

  static double mercatorV(double latitude) {
    final sinLat = math
        .sin(latitude.clamp(-85.05112878, 85.05112878) * math.pi / 180)
        .clamp(-0.9999, 0.9999);
    return 0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi);
  }

  /// Rasterises the reveal. Returns null when there is nothing to reveal.
  static Future<ExploredMask?> build({
    required List<List<LatLng>> paths,
    List<LatLng> points = const [],
    double revealRadiusMeters = 55,
    double pointRadiusMeters = 45,
    double targetTexelMeters = 6,
    int maxSize = 2048,
  }) async {
    var minU = double.infinity;
    var minV = double.infinity;
    var maxU = double.negativeInfinity;
    var maxV = double.negativeInfinity;
    var latitudeSum = 0.0;
    var count = 0;
    void include(LatLng point) {
      final u = mercatorU(point.longitude);
      final v = mercatorV(point.latitude);
      minU = math.min(minU, u);
      maxU = math.max(maxU, u);
      minV = math.min(minV, v);
      maxV = math.max(maxV, v);
      latitudeSum += point.latitude;
      count++;
    }

    for (final path in paths) {
      path.forEach(include);
    }
    points.forEach(include);
    if (count == 0) {
      return null;
    }

    final centreLatitude = latitudeSum / count;
    final metersPerUnit =
        _earthCircumference * math.cos(centreLatitude * math.pi / 180);
    final marginUnits =
        math.max(revealRadiusMeters, pointRadiusMeters) * 2 / metersPerUnit;
    final u0 = minU - marginUnits;
    final v0 = minV - marginUnits;
    final u1 = maxU + marginUnits;
    final v1 = maxV + marginUnits;
    final spanUnits = math.max(u1 - u0, v1 - v0);
    final wantedTexels = spanUnits * metersPerUnit / targetTexelMeters;
    final scale = math.min(wantedTexels, maxSize.toDouble()) / spanUnits;
    final width = math.max(16, ((u1 - u0) * scale).ceil());
    final height = math.max(16, ((v1 - v0) * scale).ceil());

    ui.Offset toPixel(LatLng point) => ui.Offset(
      (mercatorU(point.longitude) - u0) * scale,
      (mercatorV(point.latitude) - v0) * scale,
    );

    final pathWidth = math.max<double>(
      2,
      2 * revealRadiusMeters / metersPerUnit * scale,
    );
    final pointRadius = math.max(
      1.5,
      pointRadiusMeters / metersPerUnit * scale,
    );
    final feather = (pathWidth * 0.3).clamp(1.0, 24.0);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final stroke = ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = pathWidth
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, feather);
    final disc = ui.Paint()
      ..color = const ui.Color(0xFFFFFFFF)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, feather);

    for (final path in paths) {
      if (path.isEmpty) {
        continue;
      }
      if (path.length == 1) {
        canvas.drawCircle(toPixel(path.first), pathWidth / 2, disc);
        continue;
      }
      final screenPath = ui.Path();
      final first = toPixel(path.first);
      screenPath.moveTo(first.dx, first.dy);
      for (final point in path.skip(1)) {
        final offset = toPixel(point);
        screenPath.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(screenPath, stroke);
    }
    for (final point in points) {
      canvas.drawCircle(toPixel(point), pointRadius, disc);
    }

    final image = await recorder.endRecording().toImage(width, height);
    final rgba = await image.toByteData();
    if (rgba == null) {
      image.dispose();
      return null;
    }
    final alpha = Uint8List(width * height);
    for (var i = 0; i < alpha.length; i++) {
      alpha[i] = rgba.getUint8(i * 4 + 3);
    }
    return ExploredMask._(
      image: image,
      alpha: alpha,
      width: width,
      height: height,
      u0: u0,
      v0: v0,
      u1: u1,
      v1: v1,
    );
  }

  /// How explored [point] is, 0..1 (nearest texel).
  double sample(LatLng point) {
    final x = ((mercatorU(point.longitude) - u0) / spanU * width).floor();
    final y = ((mercatorV(point.latitude) - v0) / spanV * height).floor();
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return 0;
    }
    return alpha[y * width + x] / 255;
  }

  /// The RGBA pixels of [image], for uploading to a GPU texture.
  Future<ByteData?> rgba() => image.toByteData();

  void dispose() => image.dispose();
}

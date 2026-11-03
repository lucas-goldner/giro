import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/model/geo.dart';

/// Covers the map in white and reveals it only where the user has walked.
///
/// Canvas version, used over the web map and the mock map. The reveal comes
/// from a prebuilt [ExploredMask]: each frame it is one image draw with a
/// `dstOut` blend, re-projected for the camera it is told about. The
/// iOS/Android map draws the same mask on the GPU inside the map's own frame
/// (see `lib/core/map/fog_gpu.dart`).
class FogOfWar extends StatelessWidget {
  const FogOfWar({
    required this.camera,
    required this.mask,
    this.fogColor = const Color(0xFFFFFFFF),
    this.fogOpacity = 0.97,
    super.key,
  });

  /// Current camera of the underlying map (centre + zoom, no bearing/tilt).
  final ValueListenable<CameraPosition> camera;

  /// Where the user has been, or null while it is being built.
  final ValueListenable<ExploredMask?> mask;

  final Color fogColor;
  final double fogOpacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ValueListenableBuilder<CameraPosition>(
      valueListenable: camera,
      builder: (context, position, _) => ValueListenableBuilder<ExploredMask?>(
        valueListenable: mask,
        builder: (context, mask, _) => CustomPaint(
          painter: _FogPainter(
            camera: position,
            mask: mask,
            fog: fogColor.withValues(alpha: fogOpacity),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

class _FogPainter extends CustomPainter {
  _FogPainter({required this.camera, required this.mask, required this.fog});

  final CameraPosition camera;
  final ExploredMask? mask;
  final Color fog;

  /// MapLibre GL JS and the mock map both use 512 px tiles at zoom 0.
  static const _tileSize = 512.0;

  double get _worldSize => _tileSize * math.pow(2, camera.zoom);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final mask = this.mask;
    if (mask == null) {
      canvas.drawRect(rect, Paint()..color = fog);
      return;
    }
    final worldSize = _worldSize;
    final centre = Offset(
      ExploredMask.mercatorU(camera.target.longitude) * worldSize,
      ExploredMask.mercatorV(camera.target.latitude) * worldSize,
    );
    final origin = centre - size.center(Offset.zero);
    final maskRect = Rect.fromLTRB(
      mask.u0 * worldSize - origin.dx,
      mask.v0 * worldSize - origin.dy,
      mask.u1 * worldSize - origin.dx,
      mask.v1 * worldSize - origin.dy,
    );

    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(rect, Paint()..color = fog);
    if (maskRect.overlaps(rect)) {
      canvas.drawImageRect(
        mask.image,
        Rect.fromLTWH(0, 0, mask.width.toDouble(), mask.height.toDouble()),
        maskRect,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..filterQuality = FilterQuality.low,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FogPainter oldDelegate) =>
      oldDelegate.camera != camera ||
      oldDelegate.mask != mask ||
      oldDelegate.fog != fog;
}

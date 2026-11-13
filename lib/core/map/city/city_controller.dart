import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:giro/core/map/city/city_builder.dart';
import 'package:giro/core/map/city/city_gpu.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// Loads the zoom-14 building tiles around the camera for [CityGpu],
/// building each mesh in an isolate, and keeps a small cache.
class CityController {
  CityController({required this.gpu, required this.store});

  final CityGpu gpu;
  final TileStore store;

  static const tileZoom = 14;
  static const minZoom = 12.5;
  static const ring = 1;
  static const maxCachedTiles = 16;

  final _loaded = <TileId>{};
  final _loading = <TileId>{};
  final _empty = <TileId>{};
  CameraPosition? _camera;
  bool _disposed = false;

  void onCamera(CameraPosition camera) {
    _camera = camera;
    gpu.target = ml.LatLng(camera.target.latitude, camera.target.longitude);
    if (camera.zoom < minZoom) {
      gpu.visible = const [];
      return;
    }
    final centre = _tileAt(camera.target);
    final wanted = <TileId>[];
    for (var dy = -ring; dy <= ring; dy++) {
      for (var dx = -ring; dx <= ring; dx++) {
        wanted.add(TileId(tileZoom, centre.x + dx, centre.y + dy));
      }
    }
    for (final id in wanted) {
      if (!_loaded.contains(id) &&
          !_loading.contains(id) &&
          !_empty.contains(id)) {
        unawaited(_load(id));
      }
    }
    gpu.visible = [
      for (final id in wanted)
        if (_loaded.contains(id)) id,
    ];
    gpu.repaint.trigger();
    _evict(camera.target);
  }

  Future<void> setMask(ExploredMask? mask) => gpu.setMask(mask);

  Future<void> _load(TileId id) async {
    _loading.add(id);
    try {
      final bytes = await store.readTile(id);
      if (_disposed) {
        return;
      }
      if (bytes == null) {
        _empty.add(id);
        return;
      }
      final mesh = await compute(_buildInIsolate, bytes);
      if (_disposed) {
        return;
      }
      if (mesh.isEmpty) {
        _empty.add(id);
        return;
      }
      gpu.addTile(id, mesh);
      _loaded.add(id);
      final camera = _camera;
      if (camera != null) {
        onCamera(camera);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('[City] tile $id failed: $error\n$stackTrace');
      _empty.add(id);
    } finally {
      _loading.remove(id);
    }
  }

  void _evict(LatLng around) {
    if (_loaded.length <= maxCachedTiles) {
      return;
    }
    final ids = _loaded.toList()
      ..sort((a, b) => _distance(b, around).compareTo(_distance(a, around)));
    for (final id in ids.take(_loaded.length - maxCachedTiles)) {
      _loaded.remove(id);
      gpu.removeTile(id);
    }
    _empty.clear();
  }

  static TileId _tileAt(LatLng point) {
    const n = 1 << tileZoom;
    final x = ((point.longitude + 180) / 360 * n).floor().clamp(0, n - 1);
    final y = (ExploredMask.mercatorV(point.latitude) * n).floor().clamp(
      0,
      n - 1,
    );
    return TileId(tileZoom, x, y);
  }

  static double _distance(TileId id, LatLng point) {
    const n = 1 << tileZoom;
    final dx = (id.x + 0.5) / n - (point.longitude + 180) / 360;
    final dy = (id.y + 0.5) / n - ExploredMask.mercatorV(point.latitude);
    return math.sqrt(dx * dx + dy * dy);
  }

  void dispose() {
    _disposed = true;
    _loaded.clear();
  }
}

CityTileMesh _buildInIsolate(Uint8List bytes) =>
    CityBuilder.build(MvtTile.decode(bytes, only: const {'building'}));

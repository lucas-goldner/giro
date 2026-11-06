import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';
import 'package:giro/core/map/scenery/scenery_gpu.dart';
import 'package:giro/core/map/scenery/tree_scatter.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';

/// Decides which zoom-14 tiles need scenery for the current camera, loads
/// them from the [TileStore] (decoding and scattering in an isolate), keeps
/// a small cache, and feeds the nearest ones to [SceneryGpu].
class SceneryController {
  SceneryController({required this.gpu, required this.store});

  final SceneryGpu gpu;
  final TileStore store;

  /// Source zoom for scenery; the only zoom where every tile has full detail
  /// and the last one OpenFreeMap serves.
  static const tileZoom = 14;

  /// Tiles kept in memory around the camera.
  static const maxCachedTiles = 24;

  /// How many tiles around the viewport centre to load (3x3 when 1).
  static const ring = 1;

  final _cache = <TileId, SceneryBatchSource>{};
  final _loading = <TileId>{};
  final _empty = <TileId>{};
  SceneryBatchSource? _landmarks;
  ExploredMask? _mask;
  CameraPosition? _camera;
  bool _disposed = false;

  /// Called from the map's `onCameraMove`.
  void onCamera(CameraPosition camera) {
    _camera = camera;
    if (camera.zoom < SceneryGpu.minZoom - 0.5) {
      // Far out: only landmarks; keep the tile cache for the way back.
      _publish(const []);
      return;
    }
    final centre = _tileAt(camera.target);
    final wanted = <TileId>[];
    for (var dy = -ring; dy <= ring; dy++) {
      for (var dx = -ring; dx <= ring; dx++) {
        wanted.add(TileId(tileZoom, centre.x + dx, centre.y + dy));
      }
    }
    // Nearest first so the per-frame budget favours what is on screen.
    wanted.sort(
      (a, b) =>
          _distance(a, camera.target).compareTo(_distance(b, camera.target)),
    );
    for (final id in wanted) {
      if (!_cache.containsKey(id) &&
          !_loading.contains(id) &&
          !_empty.contains(id)) {
        unawaited(_load(id));
      }
    }
    _publish(wanted);
    _evict(camera.target);
  }

  /// Re-samples every cached instance against the new mask.
  void setMask(ExploredMask? mask) {
    _mask = mask;
    _cache.values.forEach(_sample);
    if (_landmarks case final source?) {
      _sample(source);
    }
    gpu.repaint.trigger();
  }

  /// Replaces the 3D models standing at saved spots.
  void setLandmarks(Iterable<SceneryInstance> instances) {
    final list = instances.toList(growable: false);
    _landmarks = list.isEmpty ? null : SceneryBatchSource(list);
    if (_landmarks case final source?) {
      _sample(source);
    }
    _republish();
  }

  void _republish() {
    final camera = _camera;
    if (camera == null) {
      _publish(const []);
    } else {
      onCamera(camera);
    }
  }

  void _publish(List<TileId> wanted) {
    // Landmarks first so the per-frame budget never drops them.
    gpu.sources = [?_landmarks, for (final id in wanted) ?_cache[id]];
    gpu.repaint.trigger();
  }

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
      final rows = await compute(_scatterInIsolate, (bytes, id.z, id.x, id.y));
      if (_disposed) {
        return;
      }
      if (rows.isEmpty) {
        _empty.add(id);
        return;
      }
      final source = SceneryBatchSource(
        rows.map(SceneryInstance.fromList).toList(growable: false),
      );
      _sample(source);
      _cache[id] = source;
      _republish();
    } on Object catch (error, stackTrace) {
      debugPrint('[Scenery] tile $id failed: $error\n$stackTrace');
      _empty.add(id);
    } finally {
      _loading.remove(id);
    }
  }

  void _sample(SceneryBatchSource source) {
    final mask = _mask;
    final list = source.instances;
    for (var i = 0; i < list.length; i++) {
      source.explored[i] = mask == null
          ? 0
          : mask.sample(LatLng(list[i].latitude, list[i].longitude));
    }
  }

  void _evict(LatLng around) {
    if (_cache.length <= maxCachedTiles) {
      return;
    }
    final ids = _cache.keys.toList()
      ..sort((a, b) => _distance(b, around).compareTo(_distance(a, around)));
    ids.take(_cache.length - maxCachedTiles).forEach(_cache.remove);
    // Forget misses too, so a later download gets another chance.
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
    _cache.clear();
  }
}

List<List<double>> _scatterInIsolate((Uint8List, int, int, int) args) {
  final (bytes, z, x, y) = args;
  final tile = MvtTile.decode(bytes);
  return TreeScatter.scatter(
    tile,
    TileId(z, x, y),
  ).map((instance) => instance.toList()).toList(growable: false);
}

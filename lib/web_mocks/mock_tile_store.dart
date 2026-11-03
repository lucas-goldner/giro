import 'dart:async';

import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';

/// Pretends to download tiles (web preview, widget tests). The map keeps
/// loading from OpenFreeMap directly.
class MockTileStore implements TileStore {
  MockTileStore({this.tickDuration = const Duration(milliseconds: 40)});

  final Duration tickDuration;
  final _regions = <OfflineRegion>[];

  @override
  String? get tileUrlTemplate => null;

  @override
  Future<void> start() async {}

  @override
  List<OfflineRegion> get regions => List.unmodifiable(_regions);

  @override
  Future<int> cachedBytes() async =>
      _regions.fold<int>(0, (sum, region) => sum + region.bytes);

  @override
  RegionEstimate estimate(LatLngBounds bounds) {
    var tiles = 0;
    var bytes = 0;
    for (var zoom = 0; zoom <= TileStore.maxZoom; zoom++) {
      final count = TileStore.tilesFor(bounds, zoom).length;
      tiles += count;
      bytes += count * TileStore.approximateBytes(zoom);
    }
    return RegionEstimate(tiles: tiles, bytes: bytes);
  }

  @override
  Stream<DownloadProgress> download(LatLngBounds bounds, {String? name}) {
    final estimate = this.estimate(bounds);
    var cancelled = false;
    late StreamController<DownloadProgress> controller;
    controller = StreamController<DownloadProgress>(
      onCancel: () => cancelled = true,
    );
    unawaited(() async {
      final perTile =
          estimate.bytes ~/ (estimate.tiles == 0 ? 1 : estimate.tiles);
      for (var done = 0; done <= estimate.tiles && !cancelled; done++) {
        controller.add(
          DownloadProgress(
            done: done,
            total: estimate.tiles,
            bytes: done * perTile,
          ),
        );
        await Future<void>.delayed(tickDuration);
      }
      if (!cancelled) {
        _regions.add(
          OfflineRegion(
            name: name ?? 'Area ${_regions.length + 1}',
            bounds: bounds,
            tiles: estimate.tiles,
            bytes: estimate.bytes,
            downloadedAt: DateTime.now(),
          ),
        );
      }
      await controller.close();
    }());
    return controller.stream;
  }

  @override
  Future<void> clear() async => _regions.clear();
}

import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:giro/core/model/geo.dart';

/// Keeps OpenFreeMap vector tiles on the device so the map works without a
/// connection and does not have to re-download your city every time.
///
/// The native implementation (`TileCacheHttp`) runs a loopback HTTP server
/// the map loads tiles from, serving cached tiles and fetching the rest from
/// OpenFreeMap; `MockTileStore` stands in on the web and in tests.
abstract class TileStore {
  /// OpenFreeMap's vector tiles stop at this zoom; MapLibre overzooms.
  static const maxZoom = 14;

  /// OpenFreeMap asks for at most this many tiles per download.
  static const maxTilesPerDownload = 3000;

  /// Where the map should load tiles from, or null to use OpenFreeMap
  /// directly (web).
  String? get tileUrlTemplate;

  Future<void> start();

  List<OfflineRegion> get regions;

  /// Bytes used by every cached tile.
  Future<int> cachedBytes();

  RegionEstimate estimate(LatLngBounds bounds);

  /// Downloads every tile of [bounds] up to [TileStore.maxZoom]. Progress
  /// events end with `done == total`; cancel by cancelling the subscription.
  Stream<DownloadProgress> download(LatLngBounds bounds, {String? name});

  Future<void> clear();

  /// Slippy-map tiles covering [bounds] at [zoom].
  static Iterable<TileId> tilesFor(LatLngBounds bounds, int zoom) sync* {
    final n = 1 << zoom;
    final minX = ((bounds.west + 180) / 360 * n).floor().clamp(0, n - 1);
    final maxX = ((bounds.east + 180) / 360 * n).floor().clamp(0, n - 1);
    final minY = _tileY(bounds.north, n).clamp(0, n - 1);
    final maxY = _tileY(bounds.south, n).clamp(0, n - 1);
    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        yield TileId(zoom, x, y);
      }
    }
  }

  static int _tileY(double latitude, int n) {
    final lat = latitude.clamp(-85.05112878, 85.05112878) * math.pi / 180;
    return ((1 - math.log(math.tan(lat) + 1 / math.cos(lat)) / math.pi) / 2 * n)
        .floor();
  }

  /// Rough bytes per tile at each zoom, from OpenFreeMap tiles over Tokyo.
  static int approximateBytes(int zoom) => switch (zoom) {
    14 => 450 * 1024,
    13 => 280 * 1024,
    12 => 160 * 1024,
    11 => 90 * 1024,
    10 => 60 * 1024,
    _ => 30 * 1024,
  };
}

class TileId extends Equatable {
  const TileId(this.z, this.x, this.y);

  final int z;
  final int x;
  final int y;

  String get path => '$z/$x/$y.pbf';

  @override
  List<Object?> get props => [z, x, y];
}

class RegionEstimate extends Equatable {
  const RegionEstimate({required this.tiles, required this.bytes});

  final int tiles;
  final int bytes;

  bool get tooLarge => tiles > TileStore.maxTilesPerDownload;

  @override
  List<Object?> get props => [tiles, bytes];
}

class DownloadProgress extends Equatable {
  const DownloadProgress({
    required this.done,
    required this.total,
    required this.bytes,
    this.failed = 0,
  });

  final int done;
  final int total;
  final int bytes;
  final int failed;

  bool get finished => done >= total;
  double get fraction => total == 0 ? 1 : done / total;

  @override
  List<Object?> get props => [done, total, bytes, failed];
}

class OfflineRegion extends Equatable {
  const OfflineRegion({
    required this.name,
    required this.bounds,
    required this.tiles,
    required this.bytes,
    required this.downloadedAt,
  });

  factory OfflineRegion.fromJson(Map<String, dynamic> json) => OfflineRegion(
    name: json['name'] as String,
    bounds: LatLngBounds(
      southWest: LatLng(
        (json['south'] as num).toDouble(),
        (json['west'] as num).toDouble(),
      ),
      northEast: LatLng(
        (json['north'] as num).toDouble(),
        (json['east'] as num).toDouble(),
      ),
    ),
    tiles: json['tiles'] as int,
    bytes: json['bytes'] as int,
    downloadedAt: DateTime.parse(json['downloadedAt'] as String),
  );

  final String name;
  final LatLngBounds bounds;
  final int tiles;
  final int bytes;
  final DateTime downloadedAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'south': bounds.south,
    'west': bounds.west,
    'north': bounds.north,
    'east': bounds.east,
    'tiles': tiles,
    'bytes': bytes,
    'downloadedAt': downloadedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [name, bounds, tiles, bytes, downloadedAt];
}

/// Formats a byte count for the HUD.
String formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
}

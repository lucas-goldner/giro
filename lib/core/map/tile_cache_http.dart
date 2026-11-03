import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';

/// On-device tile cache behind a loopback HTTP server (iOS/Android).
///
/// MapLibre loads `http://127.0.0.1:<port>/tiles/{z}/{x}/{y}.pbf`. Tiles on
/// disk are served immediately; the rest are fetched from OpenFreeMap once
/// and stored, so an area is only ever downloaded a single time. "Download
/// this area" pre-fills the same directory. The OpenFreeMap tile URL (it
/// carries a dated path that changes weekly) is resolved from its TileJSON
/// and remembered for offline starts.
class TileCacheHttp implements TileStore {
  TileCacheHttp({required this.directory, required this.userAgent});

  static const tileJsonUrl = 'https://tiles.openfreemap.org/planet';
  static const _concurrency = 4;

  final Directory directory;
  final String userAgent;

  HttpServer? _server;
  String? _upstreamTemplate;
  final _client = HttpClient()..userAgent = null;
  final _regions = <OfflineRegion>[];

  Directory get _tilesDir => Directory('${directory.path}/tiles');
  File get _tileJsonFile => File('${directory.path}/tilejson.json');
  File get _regionsFile => File('${directory.path}/regions.json');

  @override
  String? get tileUrlTemplate {
    final server = _server;
    if (server == null) {
      return null;
    }
    return 'http://127.0.0.1:${server.port}/tiles/{z}/{x}/{y}.pbf';
  }

  @override
  List<OfflineRegion> get regions => List.unmodifiable(_regions);

  @override
  Future<void> start() async {
    await _tilesDir.create(recursive: true);
    await _loadRegions();
    unawaited(_resolveUpstream());
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen(_handle, onError: (Object e) {});
    debugPrint('[TileCache] serving ${_tilesDir.path} on port ${server.port}');
  }

  Future<void> _loadRegions() async {
    if (!_regionsFile.existsSync()) {
      return;
    }
    try {
      final list = jsonDecode(await _regionsFile.readAsString()) as List;
      _regions
        ..clear()
        ..addAll(
          list.map(
            (e) => OfflineRegion.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
    } on Object catch (_) {}
  }

  Future<void> _saveRegions() => _regionsFile.writeAsString(
    jsonEncode([for (final region in _regions) region.toJson()]),
  );

  /// Reads OpenFreeMap's TileJSON for the current tile URL, falling back to
  /// the last one seen when offline.
  Future<String?> _resolveUpstream() async {
    if (_upstreamTemplate != null) {
      return _upstreamTemplate;
    }
    try {
      final request = await _client.getUrl(Uri.parse(tileJsonUrl));
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final tiles = (json['tiles'] as List).cast<String>();
      if (tiles.isNotEmpty) {
        _upstreamTemplate = tiles.first;
        await _tileJsonFile.writeAsString(body);
      }
    } on Object catch (_) {
      if (_tileJsonFile.existsSync()) {
        try {
          final json = jsonDecode(
            await _tileJsonFile.readAsString(),
          ) as Map<String, dynamic>;
          _upstreamTemplate = (json['tiles'] as List).cast<String>().first;
        } on Object catch (_) {}
      }
    }
    return _upstreamTemplate;
  }

  File _fileFor(TileId tile) =>
      File('${_tilesDir.path}/${tile.z}/${tile.x}/${tile.y}.pbf');

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      final segments = request.uri.pathSegments;
      if (segments.length != 4 ||
          segments.first != 'tiles' ||
          !segments.last.endsWith('.pbf')) {
        response.statusCode = HttpStatus.notFound;
        return;
      }
      final tile = TileId(
        int.parse(segments[1]),
        int.parse(segments[2]),
        int.parse(segments[3].substring(0, segments[3].length - 4)),
      );
      var file = _fileFor(tile);
      if (!file.existsSync()) {
        final fetched = await _fetch(tile);
        if (fetched == null) {
          response.statusCode = HttpStatus.notFound;
          return;
        }
        file = fetched;
      }
      response.headers
        ..contentType = ContentType('application', 'vnd.mapbox-vector-tile')
        ..set(HttpHeaders.cacheControlHeader, 'max-age=31536000');
      await response.addStream(file.openRead());
    } on Object catch (_) {
      response.statusCode = HttpStatus.internalServerError;
    } finally {
      await response.close();
    }
  }

  /// Downloads one tile from OpenFreeMap into the cache. Returns null when
  /// the tile does not exist (404) or the network failed.
  Future<File?> _fetch(TileId tile) async {
    final template = await _resolveUpstream();
    if (template == null) {
      return null;
    }
    final url = template
        .replaceAll('{z}', '${tile.z}')
        .replaceAll('{x}', '${tile.x}')
        .replaceAll('{y}', '${tile.y}');
    try {
      final request = await _client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        return null;
      }
      final bytes = await response.fold<BytesBuilder>(
        BytesBuilder(copy: false),
        (builder, chunk) => builder..add(chunk),
      );
      final file = _fileFor(tile);
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.part');
      await temp.writeAsBytes(bytes.takeBytes(), flush: true);
      await temp.rename(file.path);
      return file;
    } on Object catch (error) {
      debugPrint('[TileCache] ${tile.path}: $error');
      return null;
    }
  }

  @override
  Future<int> cachedBytes() async {
    var total = 0;
    if (!_tilesDir.existsSync()) {
      return 0;
    }
    await for (final entity in _tilesDir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

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
    late StreamController<DownloadProgress> controller;
    var cancelled = false;
    controller = StreamController<DownloadProgress>(
      onCancel: () => cancelled = true,
    );

    Future<void> run() async {
      final tiles = [
        for (var zoom = 0; zoom <= TileStore.maxZoom; zoom++)
          ...TileStore.tilesFor(bounds, zoom),
      ];
      var done = 0;
      var failed = 0;
      var bytes = 0;
      final queue = List<TileId>.of(tiles);
      controller.add(DownloadProgress(done: 0, total: tiles.length, bytes: 0));

      Future<void> worker() async {
        while (queue.isNotEmpty && !cancelled) {
          final tile = queue.removeAt(0);
          var file = _fileFor(tile);
          if (!file.existsSync()) {
            final fetched = await _fetch(tile);
            if (fetched == null) {
              failed++;
              done++;
              controller.add(
                DownloadProgress(
                  done: done,
                  total: tiles.length,
                  bytes: bytes,
                  failed: failed,
                ),
              );
              continue;
            }
            file = fetched;
          }
          bytes += await file.length();
          done++;
          controller.add(
            DownloadProgress(
              done: done,
              total: tiles.length,
              bytes: bytes,
              failed: failed,
            ),
          );
        }
      }

      await Future.wait([for (var i = 0; i < _concurrency; i++) worker()]);
      if (!cancelled) {
        _regions.add(
          OfflineRegion(
            name: name ?? 'Area ${_regions.length + 1}',
            bounds: bounds,
            tiles: tiles.length,
            bytes: bytes,
            downloadedAt: DateTime.now(),
          ),
        );
        await _saveRegions();
      }
      await controller.close();
    }

    unawaited(run());
    return controller.stream;
  }

  @override
  Future<void> clear() async {
    if (_tilesDir.existsSync()) {
      await _tilesDir.delete(recursive: true);
      await _tilesDir.create(recursive: true);
    }
    _regions.clear();
    if (_regionsFile.existsSync()) {
      await _regionsFile.delete();
    }
  }
}

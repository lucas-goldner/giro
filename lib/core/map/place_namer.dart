import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';

/// Names where a walk happened from the map's own vector tiles, offline.
///
/// The neighbourhood comes from the zoom-14 tile under the walk's midpoint
/// (OpenMapTiles' `place` layer: neighbourhood and quarter points), the ward
/// or city from the zoom-11 tile above it (city points). Both tiles come
/// from the [TileStore], so an area that is downloaded names walks without
/// a network and nothing leaves the device.
class PlaceNamer {
  PlaceNamer(this.store);

  final TileStore store;

  static const neighbourhoodZoom = 14;
  static const cityZoom = 11;

  /// Furthest a neighbourhood point may be from the walk to count.
  static const neighbourhoodRangeMetres = 1800.0;

  /// Furthest a city point may be (Tokyo wards are ~5 km across).
  static const cityRangeMetres = 9000.0;

  static const _maxTiles = 64;

  final _tiles = <TileId, Future<List<PlacePoint>>>{};
  final _names = <String, Future<String?>>{};

  /// "Ueno, Taito" for the walk's midpoint, or null when no tile is there.
  Future<String?> nameFor(List<LatLng> points) {
    if (points.isEmpty) {
      return Future.value();
    }
    final middle = points[points.length ~/ 2];
    final key =
        '${points.length}:${middle.latitude.toStringAsFixed(5)},'
        '${middle.longitude.toStringAsFixed(5)}';
    return _names.putIfAbsent(key, () => nameAt(middle));
  }

  Future<String?> nameAt(LatLng point) async {
    final local = _nearest(
      await _places(_tileAt(point, neighbourhoodZoom)),
      point,
      const {'neighbourhood', 'quarter', 'suburb'},
      neighbourhoodRangeMetres,
    );
    // Wards and towns first; the capital's own point (Tokyo, at Tokyo
    // Station) only when nothing else is near.
    final cities = await _places(_tileAt(point, cityZoom));
    const cityKinds = {'city', 'town', 'village'};
    final city =
        _nearest(
          cities.where((p) => !p.capital).toList(),
          point,
          cityKinds,
          cityRangeMetres,
        ) ??
        _nearest(cities, point, cityKinds, cityRangeMetres);
    if (local == null && city == null) {
      return null;
    }
    if (local == null) {
      return city!.name;
    }
    if (city == null || city.name == local.name) {
      return local.name;
    }
    return '${local.name}, ${city.name}';
  }

  Future<List<PlacePoint>> _places(TileId id) {
    final cached = _tiles.remove(id);
    if (cached != null) {
      _tiles[id] = cached;
      return cached;
    }
    final future = _load(id);
    _tiles[id] = future;
    while (_tiles.length > _maxTiles) {
      unawaited(_tiles.remove(_tiles.keys.first));
    }
    return future;
  }

  Future<List<PlacePoint>> _load(TileId id) async {
    try {
      final bytes = await store.readTile(id);
      if (bytes == null) {
        return const [];
      }
      return await compute(_decodePlaces, (bytes, id.z, id.x, id.y));
    } on Object catch (error) {
      debugPrint('[PlaceNamer] tile $id failed: $error');
      return const [];
    }
  }

  static PlacePoint? _nearest(
    List<PlacePoint> places,
    LatLng point,
    Set<String> classes,
    double rangeMetres,
  ) {
    PlacePoint? best;
    var bestMetres = rangeMetres;
    for (final place in places) {
      if (!classes.contains(place.kind)) {
        continue;
      }
      final metres = _metres(point, place.position);
      if (metres < bestMetres) {
        best = place;
        bestMetres = metres;
      }
    }
    return best;
  }

  static TileId _tileAt(LatLng point, int zoom) {
    final n = 1 << zoom;
    final x = ((point.longitude + 180) / 360 * n).floor().clamp(0, n - 1);
    final latR = point.latitude * math.pi / 180;
    final y =
        ((1 - math.log(math.tan(latR) + 1 / math.cos(latR)) / math.pi) / 2 * n)
            .floor()
            .clamp(0, n - 1);
    return TileId(zoom, x, y);
  }

  static double _metres(LatLng a, LatLng b) {
    final dLat = (a.latitude - b.latitude) * math.pi / 180;
    final dLng =
        (a.longitude - b.longitude) *
        math.pi /
        180 *
        math.cos((a.latitude + b.latitude) / 2 * math.pi / 180);
    return math.sqrt(dLat * dLat + dLng * dLng) * 6378137;
  }
}

/// A named point from the `place` layer.
@immutable
class PlacePoint {
  const PlacePoint({
    required this.name,
    required this.kind,
    required this.rank,
    required this.position,
    this.capital = false,
  });

  final String name;

  /// OpenMapTiles class: city, town, village, suburb, quarter, neighbourhood…
  final String kind;
  final int rank;
  final LatLng position;

  /// A national or regional capital point, which sits in one ward.
  final bool capital;
}

List<PlacePoint> _decodePlaces((Uint8List, int, int, int) args) {
  final (bytes, z, x, y) = args;
  final layer = MvtTile.decode(bytes, only: const {'place'}).layers['place'];
  if (layer == null) {
    return const [];
  }
  final n = 1 << z;
  final out = <PlacePoint>[];
  for (final feature in layer.features) {
    if (feature.type != MvtGeometryType.point || feature.parts.isEmpty) {
      continue;
    }
    final props = feature.properties;
    final name = (props['name:en'] ?? props['name:latin'] ?? props['name'])
        ?.toString();
    final kind = props['class']?.toString();
    if (name == null || name.isEmpty || kind == null) {
      continue;
    }
    final point = feature.parts.first.first;
    final u = (x + point.x / layer.extent) / n;
    final v = (y + point.y / layer.extent) / n;
    final lat =
        180 /
        math.pi *
        math.atan(
          0.5 *
              (math.exp(math.pi - 2 * math.pi * v) -
                  math.exp(-(math.pi - 2 * math.pi * v))),
        );
    out.add(
      PlacePoint(
        name: name,
        kind: kind,
        rank: (props['rank'] as num?)?.toInt() ?? 99,
        position: LatLng(lat, u * 360 - 180),
        capital: props['capital'] != null,
      ),
    );
  }
  return out;
}

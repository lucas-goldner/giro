import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:giro/core/model/map_overlay.dart';

/// Builds the MapLibre style JSON every map backend loads.
///
/// The base is `assets/map/sonic_style.json`: OpenFreeMap's Liberty style
/// (OpenMapTiles data, no API key) recoloured to the Sonic palette by
/// `tool/make_sonic_style.py`. Walks are added as a GeoJSON source with a
/// glow layer under a line layer, so MapLibre draws them itself in the same
/// frame as the base map. Both iOS/Android (Flutter GPU) and the web
/// (MapLibre GL JS) consume the same document.
abstract final class GiroMapStyle {
  static const asset = 'assets/map/sonic_style.json';
  static const walksSource = 'giro_walks';
  static const tilesSource = 'openmaptiles';
  static const openFreeMapBase = 'https://tiles.openfreemap.org';
  static const buildings3dLayer = 'building-3d';
  static const openFreeMapAttribution =
      '<a href="https://openfreemap.org" target="_blank">OpenFreeMap</a> '
      '<a href="https://www.openmaptiles.org/" target="_blank">&copy; '
      'OpenMapTiles</a> Data from '
      // ignore: missing_whitespace_between_adjacent_strings
      '<a href="https://www.openstreetmap.org/copyright" target="_blank">'
      'OpenStreetMap</a>';
  static const glowLayer = 'giro_walk_glow';
  static const lineLayer = 'giro_walk_line';

  static Map<String, dynamic>? _template;

  /// Loads the base style once.
  static Future<Map<String, dynamic>> template() async {
    if (_template != null) {
      return _template!;
    }
    final raw = await rootBundle.loadString(asset);
    return _template = jsonDecode(raw) as Map<String, dynamic>;
  }

  /// The complete style, with [polylines] injected, encoded as JSON.
  static String encode(
    Map<String, dynamic> template,
    Iterable<MapPolyline> polylines, {
    String? tileUrlTemplate,
    String? localBaseUrl,
  }) => jsonEncode(
    withWalks(
      template,
      polylines,
      tileUrlTemplate: tileUrlTemplate,
      localBaseUrl: localBaseUrl,
    ),
  );

  /// A copy of [template] with a `giro_walks` GeoJSON source and the walk
  /// layers inserted below the first symbol layer, so labels stay on top.
  static Map<String, dynamic> withWalks(
    Map<String, dynamic> template,
    Iterable<MapPolyline> polylines, {
    String? tileUrlTemplate,
    String? localBaseUrl,
  }) {
    final style = Map<String, dynamic>.from(template);
    if (localBaseUrl != null) {
      // Sprites and glyphs through the on-device cache as well.
      for (final key in ['sprite', 'glyphs']) {
        final value = style[key];
        if (value is String && value.startsWith(openFreeMapBase)) {
          style[key] = localBaseUrl + value.substring(openFreeMapBase.length);
        }
      }
    }
    final sources = Map<String, dynamic>.from(
      style['sources'] as Map<String, dynamic>,
    );
    if (tileUrlTemplate != null && sources.containsKey(tilesSource)) {
      // Route the vector tiles through the on-device cache instead of
      // OpenFreeMap's TileJSON; attribution stays the same.
      final original = Map<String, dynamic>.from(
        sources[tilesSource] as Map<String, dynamic>,
      );
      sources[tilesSource] = {
        'type': 'vector',
        'tiles': [tileUrlTemplate],
        'minzoom': 0,
        'maxzoom': 14,
        'attribution': original['attribution'] ?? openFreeMapAttribution,
      };
    }
    sources[walksSource] = {'type': 'geojson', 'data': geoJson(polylines)};
    style['sources'] = sources;

    final layers = List<dynamic>.from(style['layers'] as List<dynamic>);
    var insertAt = layers.indexWhere(
      (layer) => (layer as Map<String, dynamic>)['type'] == 'symbol',
    );
    if (insertAt < 0) {
      insertAt = layers.length;
    }
    layers.insertAll(insertAt, [
      _lineLayer(glowLayer, colorKey: 'glow', widthKey: 'glowWidth'),
      _lineLayer(lineLayer, colorKey: 'color', widthKey: 'width'),
    ]);
    style['layers'] = layers;
    return style;
  }

  /// A FeatureCollection with one LineString per polyline. Each feature
  /// carries its colours and widths as properties, so a single pair of
  /// data-driven layers draws every walk.
  ///
  /// A `glow_x` / `route_x` polyline pair from `SonicMap.polylines` is merged
  /// into one feature (glow under line), which is what the layers expect.
  static Map<String, dynamic> geoJson(Iterable<MapPolyline> polylines) {
    final byId = {for (final polyline in polylines) polyline.id: polyline};
    final features = <Map<String, dynamic>>[];
    final consumed = <String>{};
    for (final polyline in polylines) {
      if (consumed.contains(polyline.id) || polyline.points.length < 2) {
        continue;
      }
      var line = polyline;
      MapPolyline? glow;
      if (polyline.id.startsWith('glow_')) {
        glow = polyline;
        line = byId['route_${polyline.id.substring(5)}'] ?? polyline;
      } else if (polyline.id == 'live_glow') {
        glow = polyline;
        line = byId['live'] ?? polyline;
      } else if (polyline.id.startsWith('route_')) {
        glow = byId['glow_${polyline.id.substring(6)}'];
      } else if (polyline.id == 'live') {
        glow = byId['live_glow'];
      }
      consumed
        ..add(line.id)
        ..add(glow?.id ?? '');
      features.add({
        'type': 'Feature',
        'id': features.length,
        'properties': {
          'color': _css(line.color.toARGB32()),
          'width': line.width,
          'glow': _css((glow ?? line).color.toARGB32()),
          'glowWidth': glow?.width ?? 0,
        },
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            for (final point in line.points) [point.longitude, point.latitude],
          ],
        },
      });
    }
    return {'type': 'FeatureCollection', 'features': features};
  }

  /// Walk lines scale with zoom: at street level they are the width the
  /// user chose, towards city zoom they thin out and fade away completely,
  /// so an explored district reads as coloured map on white paper instead
  /// of a blue blot of lines.
  static Map<String, dynamic> _lineLayer(
    String id, {
    required String colorKey,
    required String widthKey,
  }) => {
    'id': id,
    'type': 'line',
    'source': walksSource,
    'layout': {'line-cap': 'round', 'line-join': 'round'},
    'paint': {
      'line-color': ['get', colorKey],
      'line-width': [
        'interpolate',
        ['exponential', 1.5],
        ['zoom'],
        9,
        [
          '*',
          ['get', widthKey],
          0.12,
        ],
        12,
        [
          '*',
          ['get', widthKey],
          0.3,
        ],
        14,
        [
          '*',
          ['get', widthKey],
          0.6,
        ],
        16,
        ['get', widthKey],
      ],
      // At city scale the uncovered colours say "explored"; the lines
      // themselves only matter at street level.
      'line-opacity': [
        'interpolate',
        ['linear'],
        ['zoom'],
        13.5,
        0,
        15,
        1,
      ],
    },
  };

  /// `rgba(r, g, b, a)` from a 32-bit ARGB value.
  static String _css(int argb) {
    final a = ((argb >> 24) & 0xFF) / 255;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return 'rgba($r, $g, $b, ${a.toStringAsFixed(3)})';
  }
}

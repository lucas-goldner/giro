import 'dart:math' as math;

import 'package:giro/core/map/mvt/mvt_decoder.dart';
import 'package:giro/core/map/tile_store.dart';

/// Where trees go: inside park, wood and grass polygons, and along
/// residential streets, scattered on a jittered grid from a seed derived
/// from the tile so they never move between frames or launches.
///
/// Pure Dart (no Flutter types) so it can run in an isolate.
abstract final class TreeScatter {
  static const earthCircumference = 40075016.686;

  /// Metres between trees per land class.
  static const spacing = <String, double>{'wood': 13, 'park': 24, 'grass': 30};

  /// Metres between street trees, and their offset from the centre line.
  static const streetSpacing = 26.0;
  static const streetOffset = 5.5;

  static const maxPerTile = 1800;

  static List<SceneryInstance> scatter(MvtTile tile, TileId id) {
    final random = math.Random(id.z * 73856093 ^ id.x * 19349663 ^ id.y);
    final n = 1 << id.z;
    final centreLat = _latitude((id.y + 0.5) / n);
    final cosLat = math.cos(centreLat * math.pi / 180);
    final out = <SceneryInstance>[];

    void addPolygons(MvtLayer? layer, double Function(MvtFeature) spacingOf) {
      if (layer == null) {
        return;
      }
      final metersPerUnit = earthCircumference * cosLat / n / layer.extent;
      for (final feature in layer.features) {
        final meters = spacingOf(feature);
        if (meters <= 0) {
          continue;
        }
        final step = meters / metersPerUnit;
        for (final polygon in feature.polygons) {
          if (polygon.area * metersPerUnit * metersPerUnit < 400) {
            continue;
          }
          final (minX, minY, maxX, maxY) = polygon.bounds;
          for (var y = minY.toDouble(); y <= maxY; y += step) {
            for (var x = minX.toDouble(); x <= maxX; x += step) {
              final px = x + (random.nextDouble() - 0.5) * step * 0.9;
              final py = y + (random.nextDouble() - 0.5) * step * 0.9;
              if (px < 0 || py < 0 || px > layer.extent || py > layer.extent) {
                continue;
              }
              if (!polygon.contains(px, py)) {
                continue;
              }
              out.add(
                _tree(random, id, layer.extent, px, py, dense: meters < 20),
              );
              if (out.length >= maxPerTile) {
                return;
              }
            }
          }
        }
      }
    }

    addPolygons(
      tile.layers['landcover'],
      (f) => spacing[f.properties['class']] ?? 0,
    );
    addPolygons(tile.layers['park'], (_) => spacing['park']!);

    final roads = tile.layers['transportation'];
    if (roads != null && out.length < maxPerTile) {
      final metersPerUnit = earthCircumference * cosLat / n / roads.extent;
      final step = streetSpacing / metersPerUnit;
      final offset = streetOffset / metersPerUnit;
      for (final feature in roads.features) {
        if (feature.properties['class'] != 'minor' ||
            feature.properties['brunnel'] != null ||
            feature.type != MvtGeometryType.line) {
          continue;
        }
        var side = random.nextBool() ? 1.0 : -1.0;
        for (final line in feature.parts) {
          var carry = step * random.nextDouble();
          for (var i = 0; i + 1 < line.length; i++) {
            final ax = line[i].x.toDouble();
            final ay = line[i].y.toDouble();
            final dx = line[i + 1].x - ax;
            final dy = line[i + 1].y - ay;
            final length = math.sqrt(dx * dx + dy * dy);
            if (length == 0) {
              continue;
            }
            final nx = -dy / length;
            final ny = dx / length;
            var t = carry;
            while (t < length) {
              final px = ax + dx * t / length + nx * offset * side;
              final py = ay + dy * t / length + ny * offset * side;
              if (px >= 0 &&
                  py >= 0 &&
                  px <= roads.extent &&
                  py <= roads.extent) {
                out.add(
                  _tree(
                    random,
                    id,
                    roads.extent,
                    px,
                    py,
                    dense: false,
                    street: true,
                  ),
                );
                if (out.length >= maxPerTile) {
                  return out;
                }
              }
              side = -side;
              t += step;
            }
            carry = t - length;
          }
        }
      }
    }
    return out;
  }

  static SceneryInstance _tree(
    math.Random random,
    TileId id,
    int extent,
    double px,
    double py, {
    required bool dense,
    bool street = false,
  }) {
    final n = 1 << id.z;
    final worldX = (id.x + px / extent) / n;
    final worldY = (id.y + py / extent) / n;
    final roll = random.nextDouble();
    final variant = street
        ? (roll < 0.85 ? SceneryKind.treeRound : SceneryKind.treeBush)
        : dense
        ? (roll < 0.6 ? SceneryKind.treeConifer : SceneryKind.treeRound)
        : (roll < 0.7
              ? SceneryKind.treeRound
              : roll < 0.85
              ? SceneryKind.treeConifer
              : SceneryKind.treeBush);
    return SceneryInstance(
      kind: variant,
      u: worldX,
      v: worldY,
      latitude: _latitude(worldY),
      scale: 0.75 + random.nextDouble() * 0.6,
      rotation: random.nextDouble() * math.pi * 2,
      tint: 0.85 + random.nextDouble() * 0.3,
    );
  }

  static double _latitude(double worldY) {
    final n = math.pi - 2 * math.pi * worldY;
    return 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }
}

enum SceneryKind { treeRound, treeConifer, treeBush, landmark }

/// One placed object: normalised Mercator position (0..1 across the world)
/// so a frame can place it with a multiply, plus how it looks.
class SceneryInstance {
  const SceneryInstance({
    required this.kind,
    required this.u,
    required this.v,
    required this.latitude,
    required this.scale,
    required this.rotation,
    required this.tint,
    this.model,
  });

  final SceneryKind kind;
  final double u;
  final double v;
  final double latitude;
  final double scale;
  final double rotation;
  final double tint;

  /// For landmarks: which model, otherwise null.
  final String? model;

  double get longitude => u * 360 - 180;

  /// Which mesh draws this instance (`SceneryMesh.of`).
  String get meshKey => model ?? kind.name;

  /// Flat list for crossing isolate boundaries.
  List<double> toList() => [
    kind.index.toDouble(),
    u,
    v,
    latitude,
    scale,
    rotation,
    tint,
  ];

  static SceneryInstance fromList(List<double> values) => SceneryInstance(
    kind: SceneryKind.values[values[0].toInt()],
    u: values[1],
    v: values[2],
    latitude: values[3],
    scale: values[4],
    rotation: values[5],
    tint: values[6],
  );
}

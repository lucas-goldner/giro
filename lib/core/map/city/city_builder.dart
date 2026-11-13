import 'dart:math' as math;
import 'dart:typed_data';

import 'package:giro/core/map/mvt/mvt_decoder.dart';

/// Turns the `building` layer of a vector tile into a mesh Giro draws
/// itself in the advanced graphics mode: walls as quads, roofs ear-clipped,
/// an ambient-occlusion value per vertex and a material class per building.
///
/// Pure Dart so it runs in an isolate. Positions are tile units for x and y
/// (0..extent, y south) and metres for z, the convention of
/// `shaders/city.vert`.
abstract final class CityBuilder {
  /// Floats per vertex: x, y, z, nx, ny, nz, ao, kindTint.
  static const floatsPerVertex = 8;

  /// Material classes, see `shaders/city.frag`.
  static const kindHouse = 0.0;
  static const kindOffice = 1.0;
  static const kindTower = 2.0;

  static CityTileMesh build(MvtTile tile) {
    final layer = tile.layers['building'];
    if (layer == null) {
      return CityTileMesh.empty(4096);
    }
    final out = _MeshWriter();
    var buildings = 0;
    for (final feature in layer.features) {
      final props = feature.properties;
      if (props['hide_3d'] == true) {
        continue;
      }
      final top = (props['render_height'] as num?)?.toDouble() ?? 8;
      final base = (props['render_min_height'] as num?)?.toDouble() ?? 0;
      if (top <= base) {
        continue;
      }
      final kind = top >= 80
          ? kindTower
          : top >= 24
          ? kindOffice
          : kindHouse;
      final tint = (feature.id % 8) / 8 * 0.9;
      for (final polygon in feature.polygons) {
        final exterior = _clean(polygon.exterior);
        if (exterior.length < 3) {
          continue;
        }
        buildings++;
        out.walls(exterior, base, top, kind + tint);
        for (final hole in polygon.holes) {
          final ring = _clean(hole);
          if (ring.length >= 3) {
            out.walls(ring, base, top, kind + tint);
          }
        }
        out.roof(exterior, top, kind + tint);
      }
    }
    return CityTileMesh(
      extent: layer.extent,
      vertices: out.vertices.toFloat32(),
      indices: out.indices.toUint32(),
      buildings: buildings,
    );
  }

  /// Drops repeated points and the closing point.
  static List<MvtPoint> _clean(List<MvtPoint> ring) {
    final out = <MvtPoint>[];
    for (final p in ring) {
      if (out.isEmpty || out.last.x != p.x || out.last.y != p.y) {
        out.add(p);
      }
    }
    if (out.length > 1 &&
        out.first.x == out.last.x &&
        out.first.y == out.last.y) {
      out.removeLast();
    }
    return out;
  }
}

class CityTileMesh {
  const CityTileMesh({
    required this.extent,
    required this.vertices,
    required this.indices,
    required this.buildings,
  });

  CityTileMesh.empty(this.extent)
    : vertices = Float32List(0),
      indices = Uint32List(0),
      buildings = 0;

  final int extent;
  final Float32List vertices;
  final Uint32List indices;
  final int buildings;

  int get vertexCount => vertices.length ~/ CityBuilder.floatsPerVertex;
  bool get isEmpty => indices.isEmpty;
}

class _MeshWriter {
  final vertices = _FloatBuffer();
  final indices = _IntBuffer();
  int _count = 0;

  int _vertex(
    double x,
    double y,
    double z,
    double nx,
    double ny,
    double nz,
    double ao,
    double kind,
  ) {
    vertices
      ..add(x)
      ..add(y)
      ..add(z)
      ..add(nx)
      ..add(ny)
      ..add(nz)
      ..add(ao)
      ..add(kind);
    return _count++;
  }

  void walls(List<MvtPoint> ring, double base, double top, double kind) {
    var cx = 0.0;
    var cy = 0.0;
    for (final p in ring) {
      cx += p.x;
      cy += p.y;
    }
    cx /= ring.length;
    cy /= ring.length;
    // Contact shadow: the foot of a wall is darker, more so on tall walls.
    final footAo = top - base > 20 ? 0.45 : 0.6;
    for (var i = 0; i < ring.length; i++) {
      final a = ring[i];
      final b = ring[(i + 1) % ring.length];
      final dx = (b.x - a.x).toDouble();
      final dy = (b.y - a.y).toDouble();
      final length = math.sqrt(dx * dx + dy * dy);
      if (length == 0) {
        continue;
      }
      var nx = dy / length;
      var ny = -dx / length;
      // Point the normal away from the footprint's centre.
      final mx = (a.x + b.x) / 2 - cx;
      final my = (a.y + b.y) / 2 - cy;
      if (nx * mx + ny * my < 0) {
        nx = -nx;
        ny = -ny;
      }
      final v0 = _vertex(
        a.x.toDouble(),
        a.y.toDouble(),
        base,
        nx,
        ny,
        0,
        footAo,
        kind,
      );
      final v1 = _vertex(
        b.x.toDouble(),
        b.y.toDouble(),
        base,
        nx,
        ny,
        0,
        footAo,
        kind,
      );
      final v2 = _vertex(
        b.x.toDouble(),
        b.y.toDouble(),
        top,
        nx,
        ny,
        0,
        1,
        kind,
      );
      final v3 = _vertex(
        a.x.toDouble(),
        a.y.toDouble(),
        top,
        nx,
        ny,
        0,
        1,
        kind,
      );
      indices
        ..add(v0)
        ..add(v1)
        ..add(v2)
        ..add(v0)
        ..add(v2)
        ..add(v3);
    }
  }

  void roof(List<MvtPoint> ring, double top, double kind) {
    final start = _count;
    for (final p in ring) {
      _vertex(p.x.toDouble(), p.y.toDouble(), top, 0, 0, 1, 1, kind);
    }
    for (final (a, b, c) in earClip(ring)) {
      indices
        ..add(start + a)
        ..add(start + b)
        ..add(start + c);
    }
  }

  /// Ear clipping for a simple polygon; falls back to a fan when the
  /// polygon is degenerate or self-intersecting.
  static List<(int, int, int)> earClip(List<MvtPoint> ring) {
    final n = ring.length;
    final out = <(int, int, int)>[];
    if (n < 3) {
      return out;
    }
    if (n == 3) {
      return [(0, 1, 2)];
    }
    // Work in a consistent winding (counter-clockwise in x right, y down
    // terms, i.e. positive signed area below).
    var area = 0.0;
    for (var i = 0; i < n; i++) {
      final a = ring[i];
      final b = ring[(i + 1) % n];
      area += a.x * b.y - b.x * a.y;
    }
    final order = List<int>.generate(n, (i) => i);
    if (area < 0) {
      order.setAll(0, order.reversed.toList());
    }
    final remaining = List<int>.of(order);
    var guard = 0;
    while (remaining.length > 3 && guard < n * n) {
      var clipped = false;
      for (var i = 0; i < remaining.length; i++) {
        final ia = remaining[(i + remaining.length - 1) % remaining.length];
        final ib = remaining[i];
        final ic = remaining[(i + 1) % remaining.length];
        final a = ring[ia];
        final b = ring[ib];
        final c = ring[ic];
        final cross = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
        if (cross <= 0) {
          continue; // reflex or flat corner
        }
        var empty = true;
        for (final other in remaining) {
          if (other == ia || other == ib || other == ic) {
            continue;
          }
          if (_inTriangle(ring[other], a, b, c)) {
            empty = false;
            break;
          }
        }
        if (!empty) {
          continue;
        }
        out.add((ia, ib, ic));
        remaining.removeAt(i);
        clipped = true;
        break;
      }
      guard++;
      if (!clipped) {
        break;
      }
    }
    if (remaining.length == 3) {
      out.add((remaining[0], remaining[1], remaining[2]));
    } else if (remaining.length > 3) {
      // Could not clip further: fan the rest so nothing is left open.
      for (var i = 1; i + 1 < remaining.length; i++) {
        out.add((remaining[0], remaining[i], remaining[i + 1]));
      }
    }
    return out;
  }

  static bool _inTriangle(MvtPoint p, MvtPoint a, MvtPoint b, MvtPoint c) {
    final d1 = (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y);
    final d2 = (p.x - c.x) * (b.y - c.y) - (b.x - c.x) * (p.y - c.y);
    final d3 = (p.x - a.x) * (c.y - a.y) - (c.x - a.x) * (p.y - a.y);
    final neg = d1 < 0 || d2 < 0 || d3 < 0;
    final pos = d1 > 0 || d2 > 0 || d3 > 0;
    return !(neg && pos);
  }
}

class _FloatBuffer {
  Float32List _data = Float32List(1 << 16);
  int _length = 0;

  void add(double value) {
    if (_length == _data.length) {
      _data = Float32List(_data.length * 2)..setAll(0, _data);
    }
    _data[_length++] = value;
  }

  Float32List toFloat32() => Float32List.sublistView(_data, 0, _length);
}

class _IntBuffer {
  Uint32List _data = Uint32List(1 << 16);
  int _length = 0;

  void add(int value) {
    if (_length == _data.length) {
      _data = Uint32List(_data.length * 2)..setAll(0, _data);
    }
    _data[_length++] = value;
  }

  Uint32List toUint32() => Uint32List.sublistView(_data, 0, _length);
}

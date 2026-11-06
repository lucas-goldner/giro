import 'dart:math' as math;
import 'dart:typed_data';

import 'package:giro/core/map/scenery/tree_scatter.dart';

/// Low-poly scenery meshes built once at startup.
///
/// Vertex format is interleaved `[x, y, z, nx, ny, nz, r, g, b]` in metres
/// with +Z up and the origin on the ground, matching `shaders/scenery.vert`.
/// Everything is flat shaded (one normal per face) so the toy look survives
/// at any size.
class SceneryMesh {
  SceneryMesh._(this.vertices, this.indices);

  final Float32List vertices;
  final Uint16List indices;

  static const floatsPerVertex = 9;

  int get vertexCount => vertices.length ~/ floatsPerVertex;
  int get indexCount => indices.length;

  static final _cache = <SceneryKind, SceneryMesh>{};

  static SceneryMesh of(SceneryKind kind) => _cache.putIfAbsent(kind, () {
    final builder = _MeshBuilder();
    switch (kind) {
      case SceneryKind.treeRound:
        _roundTree(builder);
      case SceneryKind.treeConifer:
        _conifer(builder);
      case SceneryKind.treeBush:
        _bush(builder);
      case SceneryKind.landmark:
        _beacon(builder);
    }
    return builder.build();
  });

  static const _trunk = (0.45, 0.30, 0.20);
  static const _leafLight = (0.47, 0.78, 0.36);
  static const _leafDark = (0.28, 0.62, 0.30);
  static const _needle = (0.22, 0.55, 0.36);

  static void _roundTree(_MeshBuilder b) {
    b
      ..prism(radius: 0.25, bottom: 0, top: 2.2, sides: 6, color: _trunk)
      ..blob(
        centre: (0, 0, 3.4),
        radius: 1.5,
        rings: 4,
        sides: 8,
        color: _leafLight,
      )
      ..blob(
        centre: (0.8, 0.5, 2.9),
        radius: 1,
        rings: 3,
        sides: 7,
        color: _leafDark,
      )
      ..blob(
        centre: (-0.7, -0.4, 3.0),
        radius: 0.9,
        rings: 3,
        sides: 7,
        color: _leafDark,
      );
  }

  static void _conifer(_MeshBuilder b) {
    b
      ..prism(radius: 0.22, bottom: 0, top: 1.4, sides: 6, color: _trunk)
      ..cone(radius: 1.6, bottom: 1.2, top: 3.2, sides: 7, color: _needle)
      ..cone(radius: 1.2, bottom: 2.6, top: 4.6, sides: 7, color: _leafDark)
      ..cone(radius: 0.75, bottom: 4, top: 5.8, sides: 7, color: _needle);
  }

  static void _bush(_MeshBuilder b) {
    b
      ..blob(
        centre: (0, 0, 0.9),
        radius: 0.9,
        rings: 3,
        sides: 7,
        color: _leafLight,
      )
      ..blob(
        centre: (0.6, 0.3, 0.65),
        radius: 0.65,
        rings: 3,
        sides: 6,
        color: _leafDark,
      );
  }

  /// Default landmark: a gold beacon on a navy plinth.
  static void _beacon(_MeshBuilder b) {
    b
      ..prism(
        radius: 4,
        bottom: 0,
        top: 1.2,
        sides: 8,
        color: (0.04, 0.11, 0.35),
      )
      ..prism(
        radius: 1.2,
        bottom: 1.2,
        top: 14,
        sides: 6,
        color: (0.97, 0.97, 0.99),
      )
      ..blob(
        centre: (0, 0, 16),
        radius: 3,
        rings: 4,
        sides: 10,
        color: (1, 0.77, 0),
      );
  }
}

class _MeshBuilder {
  final _vertices = <double>[];
  final _indices = <int>[];

  SceneryMesh build() => SceneryMesh._(
    Float32List.fromList(_vertices),
    Uint16List.fromList(_indices),
  );

  void _triangle(
    (double, double, double) a,
    (double, double, double) b,
    (double, double, double) c,
    (double, double, double) color,
  ) {
    final ux = b.$1 - a.$1;
    final uy = b.$2 - a.$2;
    final uz = b.$3 - a.$3;
    final vx = c.$1 - a.$1;
    final vy = c.$2 - a.$2;
    final vz = c.$3 - a.$3;
    var nx = uy * vz - uz * vy;
    var ny = uz * vx - ux * vz;
    var nz = ux * vy - uy * vx;
    final length = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (length == 0) {
      return;
    }
    nx /= length;
    ny /= length;
    nz /= length;
    final start = _vertices.length ~/ SceneryMesh.floatsPerVertex;
    for (final p in [a, b, c]) {
      _vertices.addAll([
        p.$1,
        p.$2,
        p.$3,
        nx,
        ny,
        nz,
        color.$1,
        color.$2,
        color.$3,
      ]);
    }
    _indices.addAll([start, start + 1, start + 2]);
  }

  void prism({
    required double radius,
    required double bottom,
    required double top,
    required int sides,
    required (double, double, double) color,
  }) {
    for (var i = 0; i < sides; i++) {
      final a0 = i / sides * math.pi * 2;
      final a1 = (i + 1) / sides * math.pi * 2;
      final p0 = (math.cos(a0) * radius, math.sin(a0) * radius, bottom);
      final p1 = (math.cos(a1) * radius, math.sin(a1) * radius, bottom);
      final p2 = (math.cos(a1) * radius, math.sin(a1) * radius, top);
      final p3 = (math.cos(a0) * radius, math.sin(a0) * radius, top);
      _triangle(p0, p1, p2, color);
      _triangle(p0, p2, p3, color);
      _triangle((0, 0, top), p3, p2, color);
    }
  }

  void cone({
    required double radius,
    required double bottom,
    required double top,
    required int sides,
    required (double, double, double) color,
  }) {
    for (var i = 0; i < sides; i++) {
      final a0 = i / sides * math.pi * 2;
      final a1 = (i + 1) / sides * math.pi * 2;
      final p0 = (math.cos(a0) * radius, math.sin(a0) * radius, bottom);
      final p1 = (math.cos(a1) * radius, math.sin(a1) * radius, bottom);
      _triangle(p0, p1, (0, 0, top), color);
      _triangle(p1, p0, (0, 0, bottom), color);
    }
  }

  /// A faceted sphere; [rings] latitude bands, [sides] around.
  void blob({
    required (double, double, double) centre,
    required double radius,
    required int rings,
    required int sides,
    required (double, double, double) color,
  }) {
    (double, double, double) at(int ring, int side) {
      final phi = ring / rings * math.pi;
      final theta = side / sides * math.pi * 2;
      return (
        centre.$1 + math.sin(phi) * math.cos(theta) * radius,
        centre.$2 + math.sin(phi) * math.sin(theta) * radius,
        centre.$3 + math.cos(phi) * radius,
      );
    }

    for (var r = 0; r < rings; r++) {
      for (var s = 0; s < sides; s++) {
        final p00 = at(r, s);
        final p01 = at(r, s + 1);
        final p10 = at(r + 1, s);
        final p11 = at(r + 1, s + 1);
        if (r > 0) {
          _triangle(p00, p10, p11, color);
        }
        if (r < rings - 1) {
          _triangle(p00, p11, p01, color);
        }
      }
    }
  }
}

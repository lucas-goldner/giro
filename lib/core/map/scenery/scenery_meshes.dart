import 'dart:math' as math;
import 'dart:typed_data';

import 'package:giro/core/map/scenery/landmarks.dart';
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

  static final _cache = <String, SceneryMesh>{};

  /// Every mesh key the renderer may be asked for, trees first.
  static final keys = <String>[
    for (final kind in SceneryKind.values)
      if (kind != SceneryKind.landmark) kind.name,
    for (final model in LandmarkModel.values) model.meshKey,
  ];

  static bool isTree(String key) => !key.startsWith('landmark.');

  /// The mesh for [SceneryInstance.meshKey]; built on first use.
  static SceneryMesh of(String key) => _cache.putIfAbsent(key, () {
    final builder = _MeshBuilder();
    switch (key) {
      case 'treeRound':
        _roundTree(builder);
      case 'treeConifer':
        _conifer(builder);
      case 'treeBush':
        _bush(builder);
      case 'landmark.tokyoTower':
        _tokyoTower(builder);
      case 'landmark.skytree':
        _skytree(builder);
      case 'landmark.torii':
        _torii(builder);
      case 'landmark.pagoda':
        _pagoda(builder);
      case 'landmark.dome':
        _dome(builder);
      default:
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

  static const _orange = (0.93, 0.36, 0.12);
  static const _white = (0.97, 0.97, 0.99);
  static const _steel = (0.84, 0.90, 0.96);
  static const _vermilion = (0.86, 0.22, 0.10);
  static const _wood = (0.36, 0.22, 0.15);
  static const _roofTile = (0.26, 0.31, 0.34);
  static const (double, double, double) _gold = (1, 0.77, 0);

  /// 333 m, four splayed legs simplified to tapered tiers in orange and
  /// white bands, two observatories and a spire.
  static void _tokyoTower(_MeshBuilder b) {
    for (var i = 0; i < 4; i++) {
      final bottom = i * 30.0;
      final top = bottom + 30;
      b.frustum(
        bottomRadius: 44 - i * 8.5,
        topRadius: 44 - (i + 1) * 8.5,
        bottom: bottom,
        top: top,
        sides: 4,
        color: i.isEven ? _orange : _white,
        angleOffset: math.pi / 4,
      );
    }
    b
      ..frustum(
        bottomRadius: 16,
        topRadius: 16,
        bottom: 120,
        top: 150,
        sides: 4,
        color: _white,
        angleOffset: math.pi / 4,
      )
      ..frustum(
        bottomRadius: 10,
        topRadius: 4,
        bottom: 150,
        top: 250,
        sides: 4,
        color: _orange,
        angleOffset: math.pi / 4,
      )
      ..frustum(
        bottomRadius: 7,
        topRadius: 7,
        bottom: 250,
        top: 262,
        sides: 4,
        color: _white,
        angleOffset: math.pi / 4,
      )
      ..frustum(
        bottomRadius: 2,
        topRadius: 0.6,
        bottom: 262,
        top: 333,
        sides: 4,
        color: _orange,
        angleOffset: math.pi / 4,
      );
  }

  /// 634 m: a tapered pale-blue shaft, two observation decks, antenna.
  static void _skytree(_MeshBuilder b) {
    b
      ..frustum(
        bottomRadius: 22,
        topRadius: 9,
        bottom: 0,
        top: 340,
        sides: 8,
        color: _steel,
      )
      ..frustum(
        bottomRadius: 24,
        topRadius: 24,
        bottom: 340,
        top: 360,
        sides: 10,
        color: _white,
      )
      ..frustum(
        bottomRadius: 8,
        topRadius: 6,
        bottom: 360,
        top: 445,
        sides: 8,
        color: _steel,
      )
      ..frustum(
        bottomRadius: 13,
        topRadius: 13,
        bottom: 445,
        top: 458,
        sides: 10,
        color: _white,
      )
      ..frustum(
        bottomRadius: 4,
        topRadius: 1.2,
        bottom: 458,
        top: 634,
        sides: 6,
        color: _white,
      );
  }

  /// A vermilion shrine gate, 9 m tall, 10 m wide.
  static void _torii(_MeshBuilder b) {
    b
      ..prismAt(
        x: -3.4,
        y: 0,
        radius: 0.5,
        bottom: 0,
        top: 8.2,
        sides: 6,
        color: _vermilion,
      )
      ..prismAt(
        x: 3.4,
        y: 0,
        radius: 0.5,
        bottom: 0,
        top: 8.2,
        sides: 6,
        color: _vermilion,
      )
      ..box(halfX: 4.2, halfY: 0.35, bottom: 5.6, top: 6.2, color: _vermilion)
      ..box(halfX: 5.4, halfY: 0.5, bottom: 8, top: 8.8, color: _vermilion)
      ..box(
        halfX: 5.8,
        halfY: 0.6,
        bottom: 8.8,
        top: 9.4,
        color: (0.12, 0.10, 0.10),
      );
  }

  /// A five-storey pagoda, 32 m, dark wood bodies under wide tiled roofs.
  static void _pagoda(_MeshBuilder b) {
    var z = 0.0;
    for (var tier = 0; tier < 5; tier++) {
      final half = 5.5 - tier * 0.7;
      b
        ..box(halfX: half, halfY: half, bottom: z, top: z + 4.2, color: _wood)
        ..frustum(
          bottomRadius: (half + 3.2) * math.sqrt2,
          topRadius: (half - 1.0) * math.sqrt2,
          bottom: z + 4.2,
          top: z + 6.0,
          sides: 4,
          color: _roofTile,
          angleOffset: math.pi / 4,
        );
      z += 6.0;
    }
    b.frustum(
      bottomRadius: 0.5,
      topRadius: 0.15,
      bottom: z,
      top: z + 5,
      sides: 6,
      color: _gold,
    );
  }

  /// A 60 m white dome on a low grey ring (Tokyo Dome and friends).
  static void _dome(_MeshBuilder b) {
    b
      ..frustum(
        bottomRadius: 72,
        topRadius: 70,
        bottom: 0,
        top: 14,
        sides: 16,
        color: (0.80, 0.82, 0.86),
      )
      ..blob(
        centre: (0, 0, 14),
        radius: 68,
        rings: 6,
        sides: 16,
        color: _white,
        topHalfOnly: true,
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
  }) => frustum(
    bottomRadius: radius,
    topRadius: radius,
    bottom: bottom,
    top: top,
    sides: sides,
    color: color,
  );

  void prismAt({
    required double x,
    required double y,
    required double radius,
    required double bottom,
    required double top,
    required int sides,
    required (double, double, double) color,
  }) => frustum(
    bottomRadius: radius,
    topRadius: radius,
    bottom: bottom,
    top: top,
    sides: sides,
    color: color,
    cx: x,
    cy: y,
  );

  void cone({
    required double radius,
    required double bottom,
    required double top,
    required int sides,
    required (double, double, double) color,
  }) => frustum(
    bottomRadius: radius,
    topRadius: 0,
    bottom: bottom,
    top: top,
    sides: sides,
    color: color,
  );

  /// An axis-aligned box centred on the origin in XY.
  void box({
    required double halfX,
    required double halfY,
    required double bottom,
    required double top,
    required (double, double, double) color,
  }) {
    final corners = [
      (-halfX, -halfY),
      (halfX, -halfY),
      (halfX, halfY),
      (-halfX, halfY),
    ];
    for (var i = 0; i < 4; i++) {
      final (x0, y0) = corners[i];
      final (x1, y1) = corners[(i + 1) % 4];
      _triangle((x0, y0, bottom), (x1, y1, bottom), (x1, y1, top), color);
      _triangle((x0, y0, bottom), (x1, y1, top), (x0, y0, top), color);
    }
    _triangle((-halfX, -halfY, top), (halfX, -halfY, top), (
      halfX,
      halfY,
      top,
    ), color);
    _triangle((-halfX, -halfY, top), (halfX, halfY, top), (
      -halfX,
      halfY,
      top,
    ), color);
    _triangle((-halfX, -halfY, bottom), (halfX, halfY, bottom), (
      halfX,
      -halfY,
      bottom,
    ), color);
    _triangle((-halfX, -halfY, bottom), (-halfX, halfY, bottom), (
      halfX,
      halfY,
      bottom,
    ), color);
  }

  /// A tapered tube with a bottom and a top cap; a cylinder when both
  /// radii match, a cone when [topRadius] is zero.
  void frustum({
    required double bottomRadius,
    required double topRadius,
    required double bottom,
    required double top,
    required int sides,
    required (double, double, double) color,
    double angleOffset = 0,
    double cx = 0,
    double cy = 0,
  }) {
    for (var i = 0; i < sides; i++) {
      final a0 = angleOffset + i / sides * math.pi * 2;
      final a1 = angleOffset + (i + 1) / sides * math.pi * 2;
      final p0 = (
        cx + math.cos(a0) * bottomRadius,
        cy + math.sin(a0) * bottomRadius,
        bottom,
      );
      final p1 = (
        cx + math.cos(a1) * bottomRadius,
        cy + math.sin(a1) * bottomRadius,
        bottom,
      );
      final p2 = (
        cx + math.cos(a1) * topRadius,
        cy + math.sin(a1) * topRadius,
        top,
      );
      final p3 = (
        cx + math.cos(a0) * topRadius,
        cy + math.sin(a0) * topRadius,
        top,
      );
      _triangle(p0, p1, p2, color);
      if (topRadius > 0) {
        _triangle(p0, p2, p3, color);
        _triangle((cx, cy, top), p3, p2, color);
      }
      if (bottom > 0) {
        _triangle((cx, cy, bottom), p1, p0, color);
      }
    }
  }

  /// A faceted sphere; [rings] latitude bands, [sides] around.
  void blob({
    required (double, double, double) centre,
    required double radius,
    required int rings,
    required int sides,
    required (double, double, double) color,
    bool topHalfOnly = false,
  }) {
    final span = topHalfOnly ? math.pi / 2 : math.pi;
    (double, double, double) at(int ring, int side) {
      final phi = ring / rings * span;
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
        if (r < rings - 1 || topHalfOnly) {
          _triangle(p00, p11, p01, color);
        }
      }
    }
  }
}

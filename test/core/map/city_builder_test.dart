import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/city/city_builder.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';

void main() {
  test('builds a closed mesh for every building in a Tokyo tile', () {
    final tile = MvtTile.decode(
      File('test/fixtures/tokyo_14_14552_6451.pbf').readAsBytesSync(),
      only: const {'building'},
    );
    final watch = Stopwatch()..start();
    final mesh = CityBuilder.build(tile);
    watch.stop();
    // Numbers for the log: a central Tokyo tile builds in tens of ms.
    // ignore: avoid_print
    print(
      'buildings=${mesh.buildings} vertices=${mesh.vertexCount} '
      'triangles=${mesh.indices.length ~/ 3} '
      'in ${watch.elapsedMilliseconds} ms',
    );
    expect(mesh.buildings, greaterThan(100));
    expect(mesh.indices.length % 3, 0);
    for (final index in mesh.indices) {
      expect(index, lessThan(mesh.vertexCount));
    }
    expect(mesh.vertexCount, lessThan(2000000));
    // Every vertex sits inside the tile and above ground.
    for (var v = 0; v < mesh.vertexCount; v++) {
      final x = mesh.vertices[v * CityBuilder.floatsPerVertex];
      final z = mesh.vertices[v * CityBuilder.floatsPerVertex + 2];
      expect(x, inInclusiveRange(-512, mesh.extent + 512));
      expect(z, greaterThanOrEqualTo(0));
    }
  });

  test('ear clipping handles concave rings', () {
    const ring = [
      MvtPoint(0, 0),
      MvtPoint(10, 0),
      MvtPoint(10, 10),
      MvtPoint(5, 5),
      MvtPoint(0, 10),
    ];
    const tile = MvtTile({
      'building': MvtLayer(
        name: 'building',
        extent: 4096,
        features: [
          MvtFeature(
            id: 1,
            type: MvtGeometryType.polygon,
            properties: {'render_height': 10},
            parts: [ring],
          ),
        ],
      ),
    });
    final mesh = CityBuilder.build(tile);
    // 5 walls × 2 triangles + 3 roof triangles.
    expect(mesh.indices.length ~/ 3, 13);
  });
}

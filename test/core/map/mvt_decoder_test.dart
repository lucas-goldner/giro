import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';

void main() {
  test('decodes an OpenFreeMap tile of central Tokyo', () {
    final bytes = File('test/fixtures/tokyo_14_14552_6451.pbf').readAsBytesSync();
    final tile = MvtTile.decode(bytes);

    expect(tile.layers.keys, containsAll(['building', 'landcover', 'transportation']));
    final buildings = tile.layers['building']!;
    expect(buildings.extent, 4096);
    expect(buildings.features.length, 145);
    final first = buildings.features.first;
    expect(first.type, MvtGeometryType.polygon);
    expect(first.properties['render_height'], 4);
    expect(first.polygons, isNotEmpty);
    expect(first.polygons.first.area, greaterThan(0));

    final landcover = tile.layers['landcover']!;
    final classes = landcover.features.map((f) => f.properties['class']).toSet();
    expect(classes, containsAll(['wood', 'grass']));
    final wood = landcover.features.firstWhere((f) => f.properties['class'] == 'wood');
    final polygon = wood.polygons.first;
    final (minX, minY, maxX, maxY) = polygon.bounds;
    // The polygon contains the centre of its own bounding box more often
    // than not; at least some point of the box is inside it.
    var hits = 0;
    for (var x = minX; x <= maxX; x += (maxX - minX) ~/ 8 + 1) {
      for (var y = minY; y <= maxY; y += (maxY - minY) ~/ 8 + 1) {
        if (polygon.contains(x.toDouble(), y.toDouble())) hits++;
      }
    }
    expect(hits, greaterThan(0));

    final roads = tile.layers['transportation']!;
    final minor = roads.features.where((f) => f.properties['class'] == 'minor');
    expect(minor, isNotEmpty);
    expect(minor.first.type, MvtGeometryType.line);
    expect(minor.first.parts.first.length, greaterThan(1));
  });
}

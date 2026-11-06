import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/mvt/mvt_decoder.dart';
import 'package:giro/core/map/scenery/tree_scatter.dart';
import 'package:giro/core/map/tile_store.dart';

void main() {
  test('scatters trees inside central Tokyo deterministically', () {
    final bytes = File('test/fixtures/tokyo_14_14552_6451.pbf').readAsBytesSync();
    final tile = MvtTile.decode(bytes);
    const id = TileId(14, 14552, 6451);
    final sw = Stopwatch()..start();
    final trees = TreeScatter.scatter(tile, id);
    final again = TreeScatter.scatter(tile, id);
    // ignore: avoid_print
    print('trees=${trees.length} in ${sw.elapsedMilliseconds} ms');

    expect(trees, isNotEmpty);
    expect(trees.length, lessThanOrEqualTo(TreeScatter.maxPerTile));
    expect(trees.map((t) => t.u), everyElement(inInclusiveRange(0.0, 1.0)));
    // Inside the tile's bounds: x from 14552/16384 to 14553/16384.
    expect(trees.map((t) => t.u), everyElement(inInclusiveRange(14552 / 16384, 14553 / 16384)));
    expect(trees.map((t) => t.latitude), everyElement(inInclusiveRange(35.6, 35.75)));
    expect(trees.map((t) => t.kind).toSet().length, greaterThan(1));
    expect(again.map((t) => t.toList()).toList(), trees.map((t) => t.toList()).toList());
  });
}

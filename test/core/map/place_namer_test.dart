import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/place_namer.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/web_mocks/mock_tile_store.dart';

/// Serves the two Tokyo fixtures (z14 Ueno area, z11 central Tokyo).
class _FixtureStore extends MockTileStore {
  @override
  Future<Uint8List?> readTile(TileId tile) async {
    final file = File('test/fixtures/tokyo_${tile.z}_${tile.x}_${tile.y}.pbf');
    return file.existsSync() ? file.readAsBytesSync() : null;
  }
}

void main() {
  test('names a walk by neighbourhood and ward from the tiles', () async {
    final namer = PlaceNamer(_FixtureStore());
    // Tokyo Station, inside tile 14/14552/6451: "<quarter>, <ward>", and
    // never the capital's own "Tokyo" point that sits on the station.
    final name = await namer.nameFor(const [
      LatLng(35.6800, 139.7660),
      LatLng(35.6812, 139.7671),
      LatLng(35.6820, 139.7680),
    ]);
    expect(name, isNotNull);
    expect(name, contains(', '));
    expect(name, anyOf(endsWith('Chiyoda'), endsWith('Chuo')));
    // Ueno Park: only the z11 tile covers it, so the ward alone.
    expect(await namer.nameAt(const LatLng(35.7153, 139.7739)), 'Taito');
    // Nothing stored: no name, no error.
    expect(await namer.nameAt(const LatLng(48.85, 2.35)), isNull);
  });

  test('decodes UTF-8 names', () async {
    final namer = PlaceNamer(_FixtureStore());
    final name = await namer.nameAt(const LatLng(35.6812, 139.7671));
    expect(name, isNot(contains('Ã')));
  });
}

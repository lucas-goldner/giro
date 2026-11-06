import 'package:flutter_test/flutter_test.dart';
import 'package:giro/core/map/scenery/scenery_meshes.dart';
import 'package:giro/core/map/scenery/tree_scatter.dart';

void main() {
  for (final kind in SceneryKind.values) {
    test('$kind mesh is well formed', () {
      final mesh = SceneryMesh.of(kind);
      expect(mesh.vertices.length % SceneryMesh.floatsPerVertex, 0);
      expect(mesh.indexCount % 3, 0);
      expect(mesh.indexCount, greaterThan(0));
      for (final index in mesh.indices) {
        expect(index, lessThan(mesh.vertexCount));
      }
      // Grounded, upright, and small enough to batch by the hundred.
      var minZ = double.infinity;
      var maxZ = -double.infinity;
      for (var v = 0; v < mesh.vertexCount; v++) {
        final z = mesh.vertices[v * SceneryMesh.floatsPerVertex + 2];
        minZ = z < minZ ? z : minZ;
        maxZ = z > maxZ ? z : maxZ;
        final n = mesh.vertices.sublist(
          v * SceneryMesh.floatsPerVertex + 3,
          v * SceneryMesh.floatsPerVertex + 6,
        );
        final length = n[0] * n[0] + n[1] * n[1] + n[2] * n[2];
        expect(length, closeTo(1, 1e-4));
      }
      expect(minZ, closeTo(0, 1e-9));
      expect(maxZ, greaterThan(0.5));
      expect(mesh.vertexCount, lessThan(2000));
    });
  }

  test('meshes are cached', () {
    expect(
      identical(
        SceneryMesh.of(SceneryKind.treeRound),
        SceneryMesh.of(SceneryKind.treeRound),
      ),
      isTrue,
    );
  });
}

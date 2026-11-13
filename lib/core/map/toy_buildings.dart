import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/model/geo.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// Draws MapLibre's 3D buildings as the toy city: pastel facades with a
/// procedural window grid, white clay until the user has walked past them.
///
/// For every building vertex the [ExploredMask] is sampled on the CPU when
/// the tile arrives, and the value travels to `shaders/toy_building.frag`
/// as a custom vertex attribute. Changing the mask re-evaluates every tile.
class ToyBuildings extends ml.FillExtrusionRenderer {
  factory ToyBuildings() => ToyBuildings._(RepaintSignal());

  ToyBuildings._(this._signal) : super(repaint: _signal) {
    _material = _ToyMaterial(this);
  }

  static const bundleAsset = 'assets/shaderbundles/GiroShaders.shaderbundle';

  /// The layer ids this renderer takes over (OpenFreeMap Liberty's 3D layer).
  static const layerIds = {'building-3d'};

  final RepaintSignal _signal;
  late final _ToyMaterial _material;
  ExploredMask? _mask;
  gpu.ShaderLibrary? _library;
  final _tiles = <ml.FillExtrusionTileKey, ml.FillExtrusionTile>{};
  final _hiddenParts = <ml.FillExtrusionTileKey, Set<int>>{};
  List<LandmarkClearing> _clearings = const [];
  bool _hidden = false;

  /// Hides every part (advanced graphics draws the buildings itself).
  void setHidden({required bool hidden}) {
    if (_hidden == hidden) {
      return;
    }
    _hidden = hidden;
    _signal.trigger();
  }

  Future<void> ensureLoaded() async {
    if (_library != null) {
      return;
    }
    _library = await gpu.ShaderLibrary.fromAsset(bundleAsset);
    _signal.trigger();
  }

  void setMask(ExploredMask? mask) {
    _mask = mask;
    _signal.trigger();
  }

  /// Spots whose 3D model replaces the OpenStreetMap building parts around
  /// them (within each clearing's radius).
  void setLandmarks(List<LandmarkClearing> clearings) {
    _clearings = clearings;
    for (final tile in _tiles.values) {
      _hiddenParts[tile.key] = _partsNear(tile);
    }
    _signal.trigger();
  }

  @override
  void didAddTile(ml.FillExtrusionTile tile) {
    _tiles[tile.key] = tile;
    _hiddenParts[tile.key] = _partsNear(tile);
  }

  @override
  void didRemoveTile(ml.FillExtrusionTileKey key) {
    _tiles.remove(key);
    _hiddenParts.remove(key);
  }

  @override
  bool isVisible(ml.FillExtrusionPart part) =>
      !_hidden && !(_hiddenParts[part.tile]?.contains(_partId(part)) ?? false);

  static int _partId(ml.FillExtrusionPart part) =>
      part.featureIndex << 8 | part.polygonIndex;

  Set<int> _partsNear(ml.FillExtrusionTile tile) {
    if (_clearings.isEmpty) {
      return const {};
    }
    final hidden = <int>{};
    final positions = tile.positions;
    for (final part in tile.parts) {
      if (part.vertexCount == 0) {
        continue;
      }
      var sumX = 0.0;
      var sumY = 0.0;
      for (
        var v = part.vertexOffset;
        v < part.vertexOffset + part.vertexCount;
        v++
      ) {
        sumX += positions[v * 3];
        sumY += positions[v * 3 + 1];
      }
      final centre = tile.latLngAt(
        sumX / part.vertexCount,
        sumY / part.vertexCount,
      );
      for (final clearing in _clearings) {
        if (_metres(centre, clearing.position) <= clearing.radius) {
          hidden.add(_partId(part));
          break;
        }
      }
    }
    return hidden;
  }

  static double _metres(ml.LatLng a, LatLng b) {
    final dLat = (a.latitude - b.latitude) * math.pi / 180;
    final dLng =
        (a.longitude - b.longitude) *
        math.pi /
        180 *
        math.cos((a.latitude + b.latitude) / 2 * math.pi / 180);
    return math.sqrt(dLat * dLat + dLng * dLng) * 6378137;
  }

  @override
  ml.FillExtrusionMaterial? get material =>
      _library?['ToyBuildingFragment'] == null ? null : _material;

  Float32List _exploredPerVertex(ml.FillExtrusionTile tile) {
    final values = Float32List(tile.vertexCount);
    final mask = _mask;
    if (mask == null) {
      return values;
    }
    final positions = tile.positions;
    for (var vertex = 0; vertex < tile.vertexCount; vertex++) {
      final latLng = tile.latLngAt(
        positions[vertex * 3],
        positions[vertex * 3 + 1],
      );
      values[vertex] = mask.sample(LatLng(latLng.latitude, latLng.longitude));
    }
    return values;
  }

  void dispose() {
    _tiles.clear();
    _hiddenParts.clear();
    _signal.dispose();
  }
}

/// A circle around a spot where OSM building parts give way to a model.
class LandmarkClearing {
  const LandmarkClearing({required this.position, required this.radius});

  final LatLng position;

  /// Metres.
  final double radius;
}

class _ToyMaterial extends ml.FillExtrusionMaterial {
  _ToyMaterial(this.owner);

  final ToyBuildings owner;

  @override
  gpu.Shader get fragmentShader => owner._library!['ToyBuildingFragment']!;

  @override
  int get customAttributeCount => 1;

  @override
  Float32List? customAttributes(ml.FillExtrusionTile tile) =>
      owner._exploredPerVertex(tile);
}

import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/model/geo.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// Shades MapLibre's 3D buildings white until the user has walked past them.
///
/// For every building vertex the [ExploredMask] is sampled on the CPU when
/// the tile arrives, and the value travels to `shaders/explored_building.frag`
/// as a custom vertex attribute. Changing the mask re-evaluates every tile.
class ExploredBuildings extends ml.FillExtrusionRenderer {
  factory ExploredBuildings() => ExploredBuildings._(RepaintSignal());

  ExploredBuildings._(this._signal) : super(repaint: _signal) {
    _material = _ExploredMaterial(this);
  }

  static const bundleAsset = 'assets/shaderbundles/GiroShaders.shaderbundle';

  /// The layer ids this renderer takes over (OpenFreeMap Liberty's 3D layer).
  static const layerIds = {'building-3d'};

  final RepaintSignal _signal;
  late final _ExploredMaterial _material;
  ExploredMask? _mask;
  gpu.ShaderLibrary? _library;

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

  @override
  ml.FillExtrusionMaterial? get material =>
      _library?['ExploredBuildingFragment'] == null ? null : _material;

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

  void dispose() => _signal.dispose();
}

class _ExploredMaterial extends ml.FillExtrusionMaterial {
  _ExploredMaterial(this.owner);

  final ExploredBuildings owner;

  @override
  gpu.Shader get fragmentShader => owner._library!['ExploredBuildingFragment']!;

  @override
  int get customAttributeCount => 1;

  @override
  Float32List? customAttributes(ml.FillExtrusionTile tile) =>
      owner._exploredPerVertex(tile);
}

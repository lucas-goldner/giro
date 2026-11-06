import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/map/scenery/scenery_meshes.dart';
import 'package:giro/core/map/scenery/tree_scatter.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;

/// One tile's worth of placed scenery, ready for the GPU.
class SceneryBatchSource {
  SceneryBatchSource(this.instances) : explored = Float32List(instances.length);

  final List<SceneryInstance> instances;

  /// 0..1 per instance, refreshed when the explored mask changes.
  final Float32List explored;
}

/// Draws trees and landmarks inside MapLibre's 3D pass (the map's
/// `gpuMapRenderCallback`), sharing its depth buffer so buildings occlude
/// them and they occlude each other.
///
/// Instances are packed 160 at a time into the vertex shader's uniform
/// block (`shaders/scenery.vert`), one instanced draw per batch per mesh.
class SceneryGpu {
  static const bundleAsset = 'assets/shaderbundles/GiroShaders.shaderbundle';
  static const batchSize = 160;

  /// Trees are only drawn from this zoom; below it a city has too many
  /// trees to matter and the toy buildings carry the look. Landmarks are
  /// always drawn.
  static const minZoom = 13.5;

  /// Hard cap per frame, nearest tiles first.
  static const maxInstancesPerFrame = 7000;

  final repaint = RepaintSignal();

  gpu.ShaderLibrary? _library;
  gpu.GpuContext? _context;
  gpu.RenderPipeline? _pipeline;
  gpu.HostBuffer? _uniforms;
  late gpu.UniformSlot _uniformSlot;
  final _meshBuffers = <String, _MeshBuffers>{};
  bool _loading = false;

  /// Tiles to draw, nearest first. Replaced by the controller.
  List<SceneryBatchSource> sources = const [];

  final _values = Float32List(16 + batchSize * 4 * 2);

  Future<void> ensureLoaded() async {
    if (_library != null || _loading) {
      return;
    }
    _loading = true;
    try {
      _library = await gpu.ShaderLibrary.fromAsset(bundleAsset);
    } finally {
      _loading = false;
    }
    repaint.trigger();
  }

  /// The `gpuMapRenderCallback` of [ml.MapLibreMap].
  void render(ml.MapLibreGpuRenderContext frame) {
    final transform = frame.mapTransform;
    final library = _library;
    if (library == null || transform == null || sources.isEmpty) {
      return;
    }
    _ensureResources(frame.gpuContext, library);
    final uniforms = _uniforms!..reset();
    final pass = frame.renderPass
      ..bindPipeline(_pipeline!)
      ..setPrimitiveType(gpu.PrimitiveType.triangle)
      ..setCullMode(gpu.CullMode.none)
      ..setColorBlendEnable(false);
    if (frame.hasDepthStencilAttachment) {
      pass
        ..setDepthWriteEnable(true)
        ..setDepthCompareOperation(gpu.CompareFunction.lessEqual);
    } else {
      pass.setDepthWriteEnable(false);
    }

    final vp = transform.viewProjectionMatrix;
    for (var i = 0; i < 16; i++) {
      _values[i] = vp[i];
    }
    final worldSize = transform.worldSize;
    // Thin out at the low end so zoom 13.5 is not a solid green carpet.
    final stride = transform.zoom < 14.5 ? 2 : 1;

    var budget = maxInstancesPerFrame;
    final drawTrees = transform.zoom >= minZoom;
    for (final key in SceneryMesh.keys) {
      final buffers = _meshBuffers[key];
      if (buffers == null || (!drawTrees && SceneryMesh.isTree(key))) {
        continue;
      }
      var count = 0;
      void flush() {
        if (count == 0) {
          return;
        }
        pass
          ..bindVertexBuffer(buffers.vertices)
          ..bindIndexBuffer(buffers.indices, gpu.IndexType.int16)
          ..bindUniform(
            _uniformSlot,
            uniforms.emplace(ByteData.sublistView(_values)),
          )
          ..drawIndexed(buffers.indexCount, instanceCount: count);
        count = 0;
      }

      for (final source in sources) {
        final list = source.instances;
        for (var i = 0; i < list.length; i += stride) {
          final inst = list[i];
          if (inst.meshKey != key) {
            continue;
          }
          if (budget <= 0) {
            break;
          }
          budget--;
          final base = 16 + count * 4;
          final pxPerMetre =
              worldSize /
              (math.cos(inst.latitude * math.pi / 180) *
                  2 *
                  math.pi *
                  6378137.0);
          _values[base] = inst.u * worldSize - transform.originX;
          _values[base + 1] = inst.v * worldSize - transform.originY;
          _values[base + 2] = pxPerMetre * inst.scale;
          _values[base + 3] = inst.scale;
          final p = 16 + batchSize * 4 + count * 4;
          _values[p] = inst.rotation;
          _values[p + 1] = source.explored[i];
          _values[p + 2] = inst.tint;
          _values[p + 3] = 0;
          count++;
          if (count == batchSize) {
            flush();
          }
        }
      }
      flush();
    }
  }

  void _ensureResources(gpu.GpuContext context, gpu.ShaderLibrary library) {
    if (identical(_context, context) && _pipeline != null) {
      return;
    }
    final vertex = library['SceneryVertex'];
    final fragment = library['SceneryFragment'];
    if (vertex == null || fragment == null) {
      throw StateError('Scenery shaders are missing from $bundleAsset');
    }
    _context = context;
    _pipeline = context.createRenderPipeline(vertex, fragment);
    _uniformSlot = vertex.getUniformSlot('SceneryUniforms');
    // Several batches per frame; each block holds a handful of them.
    _uniforms = context.createHostBuffer(blockLengthInBytes: 64 * 1024);
    _meshBuffers.clear();
    for (final key in SceneryMesh.keys) {
      final mesh = SceneryMesh.of(key);
      final vertices = context.createDeviceBufferWithCopy(
        ByteData.sublistView(mesh.vertices),
      );
      final indices = context.createDeviceBufferWithCopy(
        ByteData.sublistView(mesh.indices),
      );
      _meshBuffers[key] = _MeshBuffers(
        vertices: gpu.BufferView(
          vertices,
          offsetInBytes: 0,
          lengthInBytes: mesh.vertices.lengthInBytes,
        ),
        indices: gpu.BufferView(
          indices,
          offsetInBytes: 0,
          lengthInBytes: mesh.indices.lengthInBytes,
        ),
        indexCount: mesh.indexCount,
      );
    }
    debugPrint('[SceneryGpu] pipeline ready');
  }

  void dispose() {
    repaint.dispose();
    _pipeline = null;
    _uniforms = null;
    _meshBuffers.clear();
    _context = null;
  }
}

class _MeshBuffers {
  const _MeshBuffers({
    required this.vertices,
    required this.indices,
    required this.indexCount,
  });

  final gpu.BufferView vertices;
  final gpu.BufferView indices;
  final int indexCount;
}

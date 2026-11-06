import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:giro/core/map/explored_mask.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Draws the fog of war inside the MapLibre Flutter GPU frame.
///
/// One full-screen quad per frame. The fragment shader (`shaders/fog.frag`)
/// unprojects each pixel onto the ground with the frame's camera matrix and
/// samples the [ExploredMask] texture, so the reveal is pixel-exact and
/// never lags the map. When the map colour texture is available (giro's
/// fork of maplibre_flutter_gpu exposes it) the shader renders unexplored
/// ground as a pale sketch of the map; otherwise it blends white on top.
class FogGpu {
  FogGpu({
    this.fogColor = const Color(0xFFFFFFFF),
    this.fogStrength = 0.985,
    this.sketchContrast = 0.08,
  });

  final Color fogColor;

  /// 0 = no fog, 1 = fully white where unexplored.
  final double fogStrength;

  /// How much of the map's dark lines survive in unexplored areas.
  final double sketchContrast;

  static const _bundleAsset = 'assets/shaderbundles/GiroShaders.shaderbundle';

  gpu.ShaderLibrary? _library;
  gpu.GpuContext? _context;
  gpu.RenderPipeline? _pipeline;
  gpu.DeviceBuffer? _quad;
  gpu.HostBuffer? _uniforms;
  late gpu.UniformSlot _uniformSlot;
  late gpu.UniformSlot _maskSlot;
  late gpu.UniformSlot _mapSlot;
  gpu.Texture? _maskTexture;
  ExploredMask? _uploadedMask;
  ExploredMask? _mask;
  ByteData? _pendingMaskBytes;
  bool _loadingLibrary = false;

  /// Notifies the map that a new frame is needed (bind to `gpuRepaint`).
  final repaint = RepaintSignal();

  bool get isReady => _library != null;

  /// Loads the shader bundle. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (_library != null || _loadingLibrary) {
      return;
    }
    _loadingLibrary = true;
    try {
      _library = await gpu.ShaderLibrary.fromAsset(_bundleAsset);
      if (_library == null) {
        debugPrint('[FogGpu] shader bundle $_bundleAsset not found');
      }
    } finally {
      _loadingLibrary = false;
    }
    repaint.trigger();
  }

  /// Replaces the explored mask. The texture is uploaded on the next frame.
  Future<void> setMask(ExploredMask? mask) async {
    _mask = mask;
    _pendingMaskBytes = mask == null ? null : await mask.rgba();
    repaint.trigger();
  }

  /// The `gpuRenderCallback` of [MapLibreMap].
  void render(MapLibreGpuRenderContext frame) {
    final transform = frame.mapTransform;
    final library = _library;
    if (library == null || transform == null) {
      return;
    }
    _ensureResources(frame.gpuContext, library);
    _uploadMaskIfNeeded(frame.gpuContext);
    final mask = _uploadedMask;
    final maskTexture = _maskTexture;
    final mapTexture = frame.mapColorTexture;

    final viewProjection = vm.Matrix4.fromList(transform.viewProjectionMatrix);
    final inverse = vm.Matrix4.zero();
    if (inverse.copyInverse(viewProjection) == 0.0) {
      return;
    }
    final worldSize = transform.worldSize;
    final hasMask = mask != null && maskTexture != null;
    final values = Float32List(16 + 4 * 4);
    for (var i = 0; i < 16; i++) {
      values[i] = inverse.storage[i];
    }
    if (hasMask) {
      values[16] = transform.originX / worldSize - mask.u0;
      values[17] = transform.originY / worldSize - mask.v0;
      values[18] = 1 / mask.spanU;
      values[19] = 1 / mask.spanV;
    } else {
      // No mask: place it off-world so everything is unexplored.
      values[16] = 10;
      values[17] = 10;
      values[18] = 1;
      values[19] = 1;
    }
    values[20] = fogColor.r;
    values[21] = fogColor.g;
    values[22] = fogColor.b;
    values[23] = fogStrength;
    values[24] = 1 / worldSize;
    values[25] = mapTexture == null ? 0 : 1;
    values[26] = sketchContrast;
    values[27] = 0;
    values[28] = 1 / frame.physicalSize.width;
    values[29] = 1 / frame.physicalSize.height;
    values[30] = 0;
    values[31] = 0;

    final uniforms = _uniforms!..reset();
    frame.renderPass
      ..bindPipeline(_pipeline!)
      ..setPrimitiveType(gpu.PrimitiveType.triangle)
      ..setCullMode(gpu.CullMode.none)
      ..setDepthWriteEnable(false)
      ..setColorBlendEnable(mapTexture == null)
      ..setColorBlendEquation(gpu.ColorBlendEquation())
      ..bindVertexBuffer(
        gpu.BufferView(_quad!, offsetInBytes: 0, lengthInBytes: 6 * 2 * 4),
      )
      ..bindUniform(
        _uniformSlot,
        uniforms.emplace(ByteData.sublistView(values)),
      )
      ..bindTexture(
        _maskSlot,
        maskTexture ?? _placeholder(frame.gpuContext),
        sampler: gpu.SamplerOptions(
          minFilter: gpu.MinMagFilter.linear,
          magFilter: gpu.MinMagFilter.linear,
        ),
      )
      ..bindTexture(
        _mapSlot,
        mapTexture ?? _placeholder(frame.gpuContext),
        sampler: gpu.SamplerOptions(
          minFilter: gpu.MinMagFilter.linear,
          magFilter: gpu.MinMagFilter.linear,
        ),
      )
      ..draw(6);
  }

  gpu.Texture? _placeholderTexture;

  /// A transparent 1x1 texture bound to sampler slots that are unused in
  /// the current mode, so every slot the shader declares is bound.
  gpu.Texture _placeholder(gpu.GpuContext context) {
    final existing = _placeholderTexture;
    if (existing != null) {
      return existing;
    }
    final texture = context.createTexture(
      gpu.StorageMode.hostVisible,
      1,
      1,
      enableRenderTargetUsage: false,
    )..overwrite(ByteData.sublistView(Uint8List(4)));
    return _placeholderTexture = texture;
  }

  void _ensureResources(gpu.GpuContext context, gpu.ShaderLibrary library) {
    if (identical(_context, context) && _pipeline != null) {
      return;
    }
    final vertex = library['FogVertex'];
    final fragment = library['FogFragment'];
    if (vertex == null || fragment == null) {
      throw StateError('Fog shaders are missing from $_bundleAsset');
    }
    _context = context;
    _pipeline = context.createRenderPipeline(vertex, fragment);
    _uniformSlot = fragment.getUniformSlot('FogUniforms');
    _maskSlot = fragment.getUniformSlot('mask_texture');
    _mapSlot = fragment.getUniformSlot('map_texture');
    _uniforms = context.createHostBuffer(blockLengthInBytes: 4096);
    _quad = context.createDeviceBufferWithCopy(
      ByteData.sublistView(
        Float32List.fromList([-1, -1, 1, -1, 1, 1, -1, -1, 1, 1, -1, 1]),
      ),
    );
    _maskTexture = null;
    _uploadedMask = null;
    _placeholderTexture = null;
    if (_mask != null && _pendingMaskBytes == null) {
      // The context changed; re-upload the current mask on the next frame.
      unawaited(setMask(_mask));
    }
  }

  void _uploadMaskIfNeeded(gpu.GpuContext context) {
    final bytes = _pendingMaskBytes;
    final mask = _mask;
    if (bytes == null) {
      if (mask == null) {
        _maskTexture = null;
        _uploadedMask = null;
      }
      return;
    }
    _pendingMaskBytes = null;
    if (mask == null) {
      return;
    }
    final texture = context.createTexture(
      gpu.StorageMode.hostVisible,
      mask.width,
      mask.height,
      enableRenderTargetUsage: false,
    )..overwrite(bytes);
    _maskTexture = texture;
    _uploadedMask = mask;
  }

  void dispose() {
    repaint.dispose();
    _pipeline = null;
    _quad = null;
    _uniforms = null;
    _maskTexture = null;
    _placeholderTexture = null;
    _context = null;
  }
}

/// A [Listenable] the fog and building renderers poke when the map must
/// draw another frame.
class RepaintSignal extends ChangeNotifier {
  void trigger() => notifyListeners();
}

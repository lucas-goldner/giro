import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:giro/core/map/city/city_builder.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/fog_gpu.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:maplibre_flutter_gpu/maplibre_flutter_gpu.dart' as ml;
import 'package:vector_math/vector_math.dart' as vm32;
import 'package:vector_math/vector_math_64.dart' as vm;

/// Advanced graphics: draws the city's buildings itself inside MapLibre's
/// 3D pass, with a shadow map rendered from the sun each frame, materials
/// by building class, and the shadows multiplied onto the streets.
///
/// Per frame: (1) a shadow pass into an RGBA8 depth texture on a command
/// buffer of our own, submitted before the map's; (2) the buildings into
/// the shared pass with depth; (3) a ground quad per tile that darkens the
/// map where it lies in shadow. See `shaders/city*.{vert,frag}`.
class CityGpu {
  static const bundleAsset = 'assets/shaderbundles/GiroShaders.shaderbundle';
  static const shadowSize = 2048;

  /// Half-width of the shadow map's ground box, in metres around the
  /// camera target.
  static const shadowRangeMetres = 1500.0;

  /// Direction towards the sun: x east, y south, z up (south-west sun).
  static final sun = vm.Vector3(-0.55, 0.45, 0.70)..normalize();

  final repaint = RepaintSignal();

  gpu.ShaderLibrary? _library;
  gpu.GpuContext? _context;
  gpu.RenderPipeline? _city;
  gpu.RenderPipeline? _shadow;
  gpu.RenderPipeline? _ground;
  gpu.HostBuffer? _uniforms;
  late gpu.UniformSlot _citySlot;
  late gpu.UniformSlot _cityLightSlot;
  late gpu.UniformSlot _cityShadowMap;
  late gpu.UniformSlot _cityMask;
  late gpu.UniformSlot _shadowSlot;
  late gpu.UniformSlot _groundSlot;
  late gpu.UniformSlot _groundLightSlot;
  late gpu.UniformSlot _groundShadowMap;
  late gpu.UniformSlot _groundMask;
  gpu.Texture? _shadowColor;
  gpu.Texture? _shadowDepth;
  gpu.Texture? _maskTexture;
  gpu.Texture? _placeholder;
  ExploredMask? _mask;
  ExploredMask? _uploadedMask;
  ByteData? _pendingMask;
  bool _loading = false;
  final _tiles = <TileId, _CityTileBuffers>{};

  /// Tiles to draw this frame; set by the controller.
  List<TileId> visible = const [];

  /// Camera target, for the shadow box.
  ml.LatLng? target;

  bool get isReady => _library != null;

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

  Future<void> setMask(ExploredMask? mask) async {
    _mask = mask;
    _pendingMask = mask == null ? null : await mask.rgba();
    repaint.trigger();
  }

  /// Uploads a built tile; replaces an existing one.
  void addTile(TileId id, CityTileMesh mesh) {
    _pendingMeshes[id] = mesh;
    repaint.trigger();
  }

  void removeTile(TileId id) {
    _tiles.remove(id);
    _pendingMeshes.remove(id);
  }

  final _pendingMeshes = <TileId, CityTileMesh>{};

  void render(ml.MapLibreGpuRenderContext frame) {
    final transform = frame.mapTransform;
    final library = _library;
    if (library == null || transform == null) {
      return;
    }
    final context = frame.gpuContext;
    _ensureResources(context, library);
    _uploadPending(context);
    final mask = _uploadedMask;
    final tiles = [for (final id in visible) ?_tiles[id]];
    if (tiles.isEmpty) {
      return;
    }

    final worldSize = transform.worldSize;
    final centre = target == null
        ? ml.MapLibreGpuMapPosition(
            x: 0,
            y: 0,
            pixelsPerMeter: worldSize / 40075016.686,
          )
        : transform.project(target!);
    final pxPerMetre = centre.pixelsPerMeter;
    final lightVp = _lightMatrix(centre, pxPerMetre);

    final uniforms = _uniforms!..reset();
    final viewProjection = transform.viewProjectionMatrix;

    // (1) Shadow pass on our own command buffer, submitted first.
    final shadowBuffer = context.createCommandBuffer();
    final shadowPass =
        shadowBuffer.createRenderPass(
            gpu.RenderTarget.singleColor(
              gpu.ColorAttachment(
                texture: _shadowColor!,
                clearValue: vm32.Vector4(1, 1, 1, 1),
              ),
              depthStencilAttachment: gpu.DepthStencilAttachment(
                texture: _shadowDepth!,
                depthClearValue: 1,
              ),
            ),
          )
          ..bindPipeline(_shadow!)
          ..setPrimitiveType(gpu.PrimitiveType.triangle)
          ..setCullMode(gpu.CullMode.none)
          ..setDepthWriteEnable(true)
          ..setDepthCompareOperation(gpu.CompareFunction.lessEqual);
    for (final tile in tiles) {
      final values = Float32List(16 + 4);
      for (var i = 0; i < 16; i++) {
        values[i] = lightVp.storage[i];
      }
      _tileVec(tile, transform, values, 16);
      shadowPass
        ..bindVertexBuffer(tile.vertices)
        ..bindIndexBuffer(tile.indices, gpu.IndexType.int32)
        ..bindUniform(
          _shadowSlot,
          uniforms.emplace(ByteData.sublistView(values)),
        )
        ..drawIndexed(tile.indexCount);
    }
    shadowBuffer.submit();

    // Shared uniforms for the main and ground passes.
    final lightValues = Float32List(8);
    lightValues[0] = sun.x;
    lightValues[1] = sun.y;
    lightValues[2] = sun.z;
    lightValues[3] = 1.15;
    lightValues[4] = 1 / shadowSize;
    lightValues[5] = 0.0015;
    lightValues[6] = 1;
    lightValues[7] = 0.55;
    final lightView = uniforms.emplace(ByteData.sublistView(lightValues));
    final groundLight = Float32List(4);
    groundLight[0] = 1 / shadowSize;
    groundLight[1] = 0.0015;
    groundLight[2] = 0.45;
    final groundLightView = uniforms.emplace(ByteData.sublistView(groundLight));
    final shadowSampler = gpu.SamplerOptions();
    final maskSampler = gpu.SamplerOptions(
      minFilter: gpu.MinMagFilter.linear,
      magFilter: gpu.MinMagFilter.linear,
    );
    final maskTexture = _maskTexture ?? _placeholderTexture(context);

    Float32List blockFor(_CityTileBuffers tile) {
      final values = Float32List(16 + 16 + 4 + 4 + 4);
      for (var i = 0; i < 16; i++) {
        values[i] = viewProjection[i];
        values[16 + i] = lightVp.storage[i];
      }
      _tileVec(tile, transform, values, 32);
      if (mask != null) {
        values[36] = transform.originX / worldSize - mask.u0;
        values[37] = transform.originY / worldSize - mask.v0;
        values[38] = 1 / mask.spanU;
        values[39] = 1 / mask.spanV;
      } else {
        values[36] = 10;
        values[37] = 10;
        values[38] = 1;
        values[39] = 1;
      }
      values[40] = worldSize;
      return values;
    }

    // (2) Buildings.
    final pass = frame.renderPass
      ..bindPipeline(_city!)
      ..setPrimitiveType(gpu.PrimitiveType.triangle)
      ..setCullMode(gpu.CullMode.none)
      ..setColorBlendEnable(false);
    if (frame.hasDepthStencilAttachment) {
      pass
        ..setDepthWriteEnable(true)
        ..setDepthCompareOperation(gpu.CompareFunction.lessEqual);
    }
    for (final tile in tiles) {
      pass
        ..bindVertexBuffer(tile.vertices)
        ..bindIndexBuffer(tile.indices, gpu.IndexType.int32)
        ..bindUniform(
          _citySlot,
          uniforms.emplace(ByteData.sublistView(blockFor(tile))),
        )
        ..bindUniform(_cityLightSlot, lightView)
        ..bindTexture(_cityShadowMap, _shadowColor!, sampler: shadowSampler)
        ..bindTexture(_cityMask, maskTexture, sampler: maskSampler)
        ..drawIndexed(tile.indexCount);
    }

    // (3) Ground shadows, multiplied onto the map.
    pass
      ..bindPipeline(_ground!)
      ..setPrimitiveType(gpu.PrimitiveType.triangle)
      ..setCullMode(gpu.CullMode.none)
      ..setDepthWriteEnable(false)
      ..setColorBlendEnable(true)
      ..setColorBlendEquation(
        gpu.ColorBlendEquation(
          sourceColorBlendFactor: gpu.BlendFactor.zero,
          destinationColorBlendFactor: gpu.BlendFactor.sourceColor,
          sourceAlphaBlendFactor: gpu.BlendFactor.zero,
          destinationAlphaBlendFactor: gpu.BlendFactor.one,
        ),
      );
    for (final tile in tiles) {
      pass
        ..bindVertexBuffer(tile.groundQuad)
        ..bindUniform(
          _groundSlot,
          uniforms.emplace(ByteData.sublistView(blockFor(tile))),
        )
        ..bindUniform(_groundLightSlot, groundLightView)
        ..bindTexture(_groundShadowMap, _shadowColor!, sampler: shadowSampler)
        ..bindTexture(_groundMask, maskTexture, sampler: maskSampler)
        ..draw(6);
    }
  }

  /// x, y origin of the tile in origin-relative px, px per tile unit, px
  /// per metre.
  void _tileVec(
    _CityTileBuffers tile,
    ml.MapLibreGpuMapTransform transform,
    Float32List out,
    int at,
  ) {
    final n = 1 << tile.id.z;
    final worldSize = transform.worldSize;
    var x = tile.id.x / n * worldSize - transform.originX;
    final half = worldSize / 2;
    while (x > half) {
      x -= worldSize;
    }
    while (x < -half) {
      x += worldSize;
    }
    out[at] = x;
    out[at + 1] = tile.id.y / n * worldSize - transform.originY;
    out[at + 2] = worldSize / n / tile.extent;
    out[at + 3] = tile.pxPerMetre(worldSize);
  }

  /// Orthographic view from the sun over a box around the camera target.
  /// Takes origin-relative px for x/y and metres for z, like the map's own
  /// matrix, and maps depth to 0..1.
  vm.Matrix4 _lightMatrix(ml.MapLibreGpuMapPosition centre, double pxPerMetre) {
    const r = shadowRangeMetres;
    // Work in metres: scale px -> m first.
    final toMetres = vm.Matrix4.identity()
      ..setEntry(0, 0, 1 / pxPerMetre)
      ..setEntry(1, 1, 1 / pxPerMetre);
    final c = vm.Vector3(centre.x / pxPerMetre, centre.y / pxPerMetre, 0);
    final eye = c + sun * (r * 2.5);
    final view = vm.makeViewMatrix(eye, c, vm.Vector3(0, 0, 1));
    final ortho = vm.makeOrthographicMatrix(-r, r, -r, r, r * 0.5, r * 5);
    final zeroToOne = vm.Matrix4.identity()
      ..setEntry(2, 2, 0.5)
      ..setEntry(2, 3, 0.5);
    return zeroToOne.multiplied(ortho).multiplied(view).multiplied(toMetres);
  }

  void _ensureResources(gpu.GpuContext context, gpu.ShaderLibrary library) {
    if (identical(_context, context) && _city != null) {
      return;
    }
    final cityV = library['CityVertex'];
    final cityF = library['CityFragment'];
    final shadowV = library['CityShadowVertex'];
    final shadowF = library['CityShadowFragment'];
    final groundV = library['GroundShadowVertex'];
    final groundF = library['GroundShadowFragment'];
    if ([cityV, cityF, shadowV, shadowF, groundV, groundF].contains(null)) {
      throw StateError('City shaders are missing from $bundleAsset');
    }
    _context = context;
    _city = context.createRenderPipeline(cityV!, cityF!);
    _shadow = context.createRenderPipeline(shadowV!, shadowF!);
    _ground = context.createRenderPipeline(groundV!, groundF!);
    _citySlot = cityV.getUniformSlot('CityUniforms');
    _cityLightSlot = cityF.getUniformSlot('LightUniforms');
    _cityShadowMap = cityF.getUniformSlot('shadow_map');
    _cityMask = cityF.getUniformSlot('mask_texture');
    _shadowSlot = shadowV.getUniformSlot('ShadowUniforms');
    _groundSlot = groundV.getUniformSlot('GroundUniforms');
    _groundLightSlot = groundF.getUniformSlot('GroundLight');
    _groundShadowMap = groundF.getUniformSlot('shadow_map');
    _groundMask = groundF.getUniformSlot('mask_texture');
    _uniforms = context.createHostBuffer(blockLengthInBytes: 256 * 1024);
    _shadowColor = context.createTexture(
      gpu.StorageMode.devicePrivate,
      shadowSize,
      shadowSize,
    );
    _shadowDepth = context.createTexture(
      gpu.StorageMode.deviceTransient,
      shadowSize,
      shadowSize,
      format: context.defaultDepthStencilFormat,
      enableShaderReadUsage: false,
    );
    _tiles.clear();
    _maskTexture = null;
    _uploadedMask = null;
    _placeholder = null;
    if (_mask != null && _pendingMask == null) {
      unawaited(setMask(_mask));
    }
    debugPrint('[CityGpu] pipelines ready');
  }

  void _uploadPending(gpu.GpuContext context) {
    if (_pendingMeshes.isNotEmpty) {
      for (final MapEntry(key: id, value: mesh) in _pendingMeshes.entries) {
        if (mesh.isEmpty) {
          _tiles.remove(id);
          continue;
        }
        _tiles[id] = _CityTileBuffers.upload(context, id, mesh);
      }
      _pendingMeshes.clear();
    }
    final bytes = _pendingMask;
    final mask = _mask;
    if (bytes != null && mask != null) {
      _pendingMask = null;
      _maskTexture = context.createTexture(
        gpu.StorageMode.hostVisible,
        mask.width,
        mask.height,
        enableRenderTargetUsage: false,
      )..overwrite(bytes);
      _uploadedMask = mask;
    } else if (mask == null) {
      _maskTexture = null;
      _uploadedMask = null;
    }
  }

  gpu.Texture _placeholderTexture(gpu.GpuContext context) =>
      _placeholder ??= context.createTexture(
        gpu.StorageMode.hostVisible,
        1,
        1,
        enableRenderTargetUsage: false,
      )..overwrite(ByteData.sublistView(Uint8List(4)));

  void dispose() {
    repaint.dispose();
    _tiles.clear();
    _pendingMeshes.clear();
    _city = null;
    _shadow = null;
    _ground = null;
    _uniforms = null;
    _shadowColor = null;
    _shadowDepth = null;
    _maskTexture = null;
    _placeholder = null;
    _context = null;
  }
}

class _CityTileBuffers {
  _CityTileBuffers({
    required this.id,
    required this.extent,
    required this.vertices,
    required this.indices,
    required this.indexCount,
    required this.groundQuad,
    required this.cosLat,
  });

  factory _CityTileBuffers.upload(
    gpu.GpuContext context,
    TileId id,
    CityTileMesh mesh,
  ) {
    final vertices = context.createDeviceBufferWithCopy(
      ByteData.sublistView(mesh.vertices),
    );
    final indices = context.createDeviceBufferWithCopy(
      ByteData.sublistView(mesh.indices),
    );
    final e = mesh.extent.toDouble();
    final quad = context.createDeviceBufferWithCopy(
      ByteData.sublistView(
        Float32List.fromList([0, 0, e, 0, e, e, 0, 0, e, e, 0, e]),
      ),
    );
    final n = 1 << id.z;
    final v = (id.y + 0.5) / n;
    final lat = math.atan(_sinh(math.pi * (1 - 2 * v)));
    return _CityTileBuffers(
      id: id,
      extent: mesh.extent,
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
      indexCount: mesh.indices.length,
      groundQuad: gpu.BufferView(quad, offsetInBytes: 0, lengthInBytes: 48),
      cosLat: math.cos(lat),
    );
  }

  final TileId id;
  final int extent;
  final gpu.BufferView vertices;
  final gpu.BufferView indices;
  final int indexCount;
  final gpu.BufferView groundQuad;
  final double cosLat;

  double pxPerMetre(double worldSize) =>
      worldSize / (cosLat * 2 * math.pi * 6378137.0);

  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
}

# Giro's fork of maplibre_flutter_gpu

This directory is [hyshu/maplibre_flutter_gpu](https://github.com/hyshu/maplibre_flutter_gpu)
**0.2.0** (the pub.dev archive) plus one feature Giro needs. Everything
else is untouched so the diff against upstream stays reviewable:

```
git diff --no-index <pub-cache>/maplibre_flutter_gpu-0.2.0 packages/maplibre_flutter_gpu
```

## What is changed

`MapLibreMap.gpuOverlayReadsMapColor` (default `false`). When set, the
`gpuRenderCallback` pass no longer draws over the map texture. It targets a
third pooled texture, which is cleared, and receives the finished map as
`MapLibreGpuRenderContext.mapColorTexture`. That overlay texture is what the
widget presents, so the callback must produce every pixel. Giro uses it for
the fog of war: unexplored ground is a pale sketch of the map, explored
ground keeps its colours (`shaders/fog.frag` in the app).

Files: `lib/src/gpu/render_context.dart`, `lib/src/widgets/maplibre_map.dart`,
`lib/src/widgets/map/map_composition.dart`,
`lib/src/widgets/map_gpu_painter.dart`.

## Binaries

The MapLibre Native bridge (`darwin/.../MapLibreBridge.xcframework`,
`android/src/main/jniLibs`) is prebuilt upstream and far too large for git.
`tool/fetch_maplibre_native.sh` downloads the upstream pub archive and drops
the binaries in place; `.gitignore` here keeps them out of commits. Nothing
under `native/` is modified, so the upstream binaries stay valid.

## Upstreaming

The change is self-contained and worth a pull request to upstream as
"gpuRenderCallback post-processing mode". Once merged, delete this directory
and depend on the hosted package again.

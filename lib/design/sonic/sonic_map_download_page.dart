import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/map_settings_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/l10n.dart';
import 'package:giro/core/map/explored_mask.dart';
import 'package:giro/core/map/tile_store.dart';
import 'package:giro/core/model/geo.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Map data: pick an area on the map and store its tiles on the device.
///
/// Shown once on first launch ([firstRun]) and later from Options. The
/// area is simply what the map shows: pan and zoom until your city fits,
/// then download. Zoom levels 0 to 14 are stored, which is everything
/// OpenFreeMap serves; MapLibre overzooms beyond that.
class SonicMapDownloadPage extends StatefulWidget {
  const SonicMapDownloadPage({this.firstRun = false, super.key});

  final bool firstRun;

  @override
  State<SonicMapDownloadPage> createState() => _SonicMapDownloadPageState();
}

class _SonicMapDownloadPageState extends State<SonicMapDownloadPage> {
  CameraPosition? _camera;
  Size _mapSize = Size.zero;
  StreamSubscription<DownloadProgress>? _download;
  DownloadProgress? _progress;
  int _cachedBytes = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshCached());
  }

  @override
  void dispose() {
    unawaited(_download?.cancel());
    super.dispose();
  }

  Future<void> _refreshCached() async {
    final bytes = await context.read<TileStore>().cachedBytes();
    if (mounted) {
      setState(() => _cachedBytes = bytes);
    }
  }

  /// The area the map currently shows (bearing and tilt ignored).
  LatLngBounds? get _visibleBounds {
    final camera = _camera;
    if (camera == null || _mapSize.isEmpty) {
      return null;
    }
    final worldSize = 512.0 * math.pow(2, camera.zoom);
    final centreU = ExploredMask.mercatorU(camera.target.longitude);
    final centreV = ExploredMask.mercatorV(camera.target.latitude);
    final halfU = _mapSize.width / 2 / worldSize;
    final halfV = _mapSize.height / 2 / worldSize;
    double lon(double u) => u * 360 - 180;
    double lat(double v) {
      final n = math.pi - 2 * math.pi * v;
      return 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
    }

    return LatLngBounds(
      southWest: LatLng(lat(centreV + halfV), lon(centreU - halfU)),
      northEast: LatLng(lat(centreV - halfV), lon(centreU + halfU)),
    );
  }

  void _start() {
    final bounds = _visibleBounds;
    if (bounds == null || _download != null) {
      return;
    }
    final store = context.read<TileStore>();
    setState(
      () => _progress = const DownloadProgress(done: 0, total: 1, bytes: 0),
    );
    _download = store
        .download(bounds, name: context.l10n.areaName(store.regions.length + 1))
        .listen(
          (progress) => setState(() => _progress = progress),
          onDone: () async {
            _download = null;
            await _refreshCached();
            if (mounted) {
              setState(() {});
            }
          },
          onError: (Object _) => setState(() => _download = null),
        );
  }

  Future<void> _cancel() async {
    await _download?.cancel();
    setState(() {
      _download = null;
      _progress = null;
    });
    await _refreshCached();
  }

  Future<void> _clear() async {
    await context.read<TileStore>().clear();
    await _refreshCached();
    if (mounted) {
      setState(() => _progress = null);
    }
  }

  void _leave() {
    unawaited(context.read<MapSettingsCubit>().markMapDownloadPrompted());
    context.navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TileStore>();
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final settings = context.watch<MapSettingsCubit>().state;
    final initialCamera = CameraPosition(
      target: routes.isNotEmpty
          ? routes.first.coordinates.first
          : SonicMap.tokyo,
      zoom: 11,
    );
    // Until the map reports where it looks, the area is where it starts.
    _camera ??= initialCamera;
    final bounds = _visibleBounds;
    final estimate = bounds == null ? null : store.estimate(bounds);
    final progress = _progress;
    final downloading = _download != null;
    final finished = progress != null && progress.finished && !downloading;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    _mapSize = constraints.biggest;
                    return PlatformMapView(
                      initialCameraPosition: initialCamera,
                      polylines: SonicMap.polylines(
                        routes,
                        settings: settings,
                        faint: true,
                      ),
                      fogOfWar: false,
                      compassEnabled: false,
                      onCameraMove: (camera) =>
                          setState(() => _camera = camera),
                    );
                  },
                ),
                // The area frame: everything inside is what gets stored.
                IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: SonicTheme.gold, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 14, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SonicHudChip(
                            onTap: _leave,
                            child: Text(
                              widget.firstRun ? l10n.skip : l10n.back,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SonicChip(l10n.frameYourCity),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SonicPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mapDataOffline, style: SonicTheme.label),
                const SizedBox(height: 4),
                SonicHudText(l10n.downloadArea, size: 34),
                const SizedBox(height: 6),
                Text(
                  widget.firstRun
                      ? l10n.downloadIntroFirstRun
                      : l10n.downloadIntro,
                  style: SonicTheme.body,
                ),
                const SizedBox(height: 12),
                if (downloading && progress != null) ...[
                  _ProgressBar(progress: progress),
                  const SizedBox(height: 10),
                  SonicButton(
                    label: l10n.cancel,
                    caption: l10n.downloadCancelCaption(
                      progress.done,
                      progress.total,
                      formatBytes(progress.bytes),
                    ),
                    color: SonicTheme.red,
                    shadow: SonicTheme.redDeep,
                    height: 54,
                    onTap: _cancel,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: SonicStat(
                          value: estimate == null ? '–' : '${estimate.tiles}',
                          label: l10n.tilesUnit,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SonicStat(
                          value: estimate == null
                              ? '–'
                              : '~${formatBytes(estimate.bytes)}',
                          label: l10n.downloadUnit,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SonicStat(
                          value: formatBytes(_cachedBytes),
                          label: l10n.storedUnit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (finished)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SonicRow(
                        label: l10n.doneLabel,
                        value: l10n.areaStored,
                        gold: true,
                      ),
                    ),
                  if (estimate != null && estimate.tooLarge)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SonicRow(
                        label: l10n.tooBig,
                        value: l10n.zoomInALittle,
                      ),
                    ),
                  SonicButton(
                    label: finished
                        ? l10n.downloadAnotherArea
                        : l10n.downloadLabel,
                    caption: estimate == null || estimate.tooLarge
                        ? l10n.frameSmallerArea
                        : l10n.zoomRangeCaption,
                    semanticsLabel: l10n.downloadAreaSemantics,
                    color: estimate == null || estimate.tooLarge
                        ? SonicTheme.blue
                        : SonicTheme.gold,
                    shadow: estimate == null || estimate.tooLarge
                        ? SonicTheme.blueDeep
                        : SonicTheme.goldDeep,
                    height: 56,
                    onTap: estimate == null || estimate.tooLarge
                        ? () {}
                        : _start,
                  ),
                  if (store.regions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.areasStored(store.regions.length),
                      style: SonicTheme.body,
                    ),
                    const SizedBox(height: 6),
                    SonicButton(
                      label: l10n.clearMapData,
                      caption: l10n.freesBytes(formatBytes(_cachedBytes)),
                      height: 46,
                      fontSize: 15,
                      onTap: _clear,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final DownloadProgress progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(context.l10n.downloading, style: SonicTheme.label),
          ),
          Text('${(progress.fraction * 100).round()}%', style: SonicTheme.stat),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 14,
          child: Semantics(
            label: context.l10n.downloadProgressSemantics,
            value: context.l10n.percentValue((progress.fraction * 100).round()),
            child: LinearProgressIndicator(
              value: progress.fraction,
              backgroundColor: SonicTheme.navyDeep,
              color: SonicTheme.gold,
            ),
          ),
        ),
      ),
    ],
  );
}

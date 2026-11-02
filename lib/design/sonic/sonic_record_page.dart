import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:giro/core/router.dart';
import 'package:giro/core/widgets/platform_map_view.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_map.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:giro/record_walk/cubit/record_walk_cubit.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// Recording as an act in progress: HUD timer, a gold ring gauge for new
/// ground, live stats, and the fog uncovering behind the glowing dot.
class SonicRecordPage extends StatelessWidget {
  const SonicRecordPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => RecordWalkCubit(context.read<WalkRoutesRepo>()),
    child: const _SonicRecord(),
  );
}

class _SonicRecord extends StatefulWidget {
  const _SonicRecord();

  @override
  State<_SonicRecord> createState() => _SonicRecordState();
}

class _SonicRecordState extends State<_SonicRecord> {
  Timer? _clock;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _syncClock(RecordWalkState state) {
    if (state is RecordWalkRecording && _clock == null) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        final start = state.startDate;
        if (start != null && mounted) {
          setState(() => _elapsed = DateTime.now().difference(start));
        }
      });
    } else if (state is! RecordWalkRecording) {
      _clock?.cancel();
      _clock = null;
    }
  }

  String _clockLabel() {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final explored = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    return BlocConsumer<RecordWalkCubit, RecordWalkState>(
      listener: (context, state) {
        _syncClock(state);
        if (state is RecordWalkFinishedRecording && state.route != null) {
          context.read<WalkRoutesCubit>().addRoute(state.route!);
        }
      },
      builder: (context, state) {
        final points = state.coordinates;
        final live = state is RecordWalkFinishedRecording && state.route != null
            ? state.route!
            : WalkRoute(
                coordinates: points,
                startDate: state.startDate ?? DateTime.now(),
                endDate: DateTime.now(),
              );
        // Once saved, the walk is part of `explored`; compare against the
        // walks that came before it only.
        final newShare = points.length > 1
            ? SonicStats.newGroundShare(
                live,
                SonicStats.earlierThan(live, explored),
              )
            : 0.0;
        final newMeters = live.distanceMeters * newShare;
        final target = points.isNotEmpty
            ? points.last
            : explored.isNotEmpty
            ? explored.first.coordinates.last
            : SonicMap.tokyo;

        return Scaffold(
          backgroundColor: SonicTheme.navy,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PlatformMapView(
                      key: const ValueKey('sonic_record_map'),
                      initialCameraPosition: CameraPosition(
                        target: target,
                        zoom: 16,
                      ),
                      polylines: {
                        ...SonicMap.polylines(explored, faint: true),
                        if (points.isNotEmpty) ...SonicMap.live(points),
                      },
                      myLocationEnabled: true,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.isRecording
                                        ? 'ACT 2 · RECORDING'
                                        : state.isFinished
                                        ? 'ACT 2 · CLEAR'
                                        : 'ACT 2 · READY',
                                    style: SonicTheme.label.copyWith(
                                      color: SonicTheme.white,
                                      shadows: const [
                                        Shadow(
                                          color: SonicTheme.navy,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  SonicHudText(_clockLabel(), size: 50),
                                ],
                              ),
                              const Spacer(),
                              _NewGroundGauge(share: newShare),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 118),
                          child: SonicHudChip(
                            onTap: context.navigator.pop,
                            child: const Text('◀  BACK'),
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
                    Text(
                      state.isRecording
                          ? 'LIVE'
                          : state.isFinished
                          ? 'RESULT'
                          : 'PRESS GO TO START',
                      style: SonicTheme.label,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SonicStat(
                            value: SonicTheme.kilometres(live.distanceMeters),
                            label: 'km',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SonicStat(value: _pace(live), label: '/km'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SonicStat(
                            value: '+${newMeters.round()}',
                            label: 'm new',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: switch (state) {
                        RecordWalkInitial() => SonicButton(
                          label: 'GO!',
                          caption: 'Start recording',
                          semanticsLabel: 'Start recording',
                          color: SonicTheme.red,
                          shadow: SonicTheme.redDeep,
                          fontSize: 26,
                          height: 56,
                          onTap: context.read<RecordWalkCubit>().startRecording,
                        ),
                        RecordWalkRecording() => SonicButton(
                          label: 'Stop',
                          caption: 'Finish stage',
                          semanticsLabel: 'Stop recording',
                          color: SonicTheme.red,
                          shadow: SonicTheme.redDeep,
                          fontSize: 24,
                          height: 56,
                          onTap: context
                              .read<RecordWalkCubit>()
                              .finishRecording,
                        ),
                        RecordWalkFinishedRecording() => SonicButton(
                          label: 'Stage clear!',
                          caption: 'View result',
                          semanticsLabel: 'View finished recording',
                          color: SonicTheme.gold,
                          shadow: SonicTheme.goldDeep,
                          fontSize: 22,
                          height: 56,
                          onTap: () => context.navigator.pushReplacementNamed(
                            AppRoutes.walkDetail,
                            arguments: state.route,
                          ),
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _pace(WalkRoute live) {
    if (live.distanceMeters < 20) {
      return '--:--';
    }
    final secondsPerKm = live.duration.inSeconds / (live.distanceMeters / 1000);
    final minutes = (secondsPerKm ~/ 60).clamp(0, 99);
    final seconds = (secondsPerKm % 60).round().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Gold conic gauge showing the share of this walk that is new ground.
class _NewGroundGauge extends StatelessWidget {
  const _NewGroundGauge({required this.share});

  final double share;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${(share * 100).round()} percent new ground',
    child: Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: const [
            SonicTheme.gold,
            SonicTheme.gold,
            Color(0xFF1F3FA0),
            Color(0xFF1F3FA0),
          ],
          stops: [0, share, share, 1],
        ),
        boxShadow: const [BoxShadow(offset: Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: SonicTheme.navy,
        ),
        alignment: Alignment.center,
        child: Text(
          '${(share * 100).round()}%',
          style: const TextStyle(
            fontFamily: SonicTheme.font,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: 17,
            color: SonicTheme.gold,
          ),
        ),
      ),
    ),
  );
}

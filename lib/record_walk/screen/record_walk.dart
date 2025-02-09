import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/core/widgets/adaptive_scaffold.dart';
import 'package:giro/record_walk/cubit/record_walk_cubit.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class RecordWalkPage extends StatelessWidget {
  const RecordWalkPage({super.key});
  static const String routeName = '/record_walk';

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => RecordWalkCubit(
          context.read<WalkRoutesRepoMmkvImpl>(),
        ),
        child: const RecordWalk(),
      );
}

class RecordWalk extends StatefulWidget {
  const RecordWalk({super.key});

  @override
  _RecordWalkState createState() => _RecordWalkState();
}

class _RecordWalkState extends State<RecordWalk>
    with SingleTickerProviderStateMixin {
  /// Controls the animation for the new segment.
  late AnimationController _controller;
  late Animation<double> _animation;

  /// A notifier that holds the current set of polylines.
  /// The PlatformMap will rebuild only its overlay when this changes.
  final ValueNotifier<Set<Polyline>> _polylineNotifier =
      ValueNotifier(const {});

  /// We keep track of the latest state so we can update the animation.
  RecordWalkState? _latestState;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(_updatePolylines);
  }

  @override
  void dispose() {
    _controller.dispose();
    _polylineNotifier.dispose();
    super.dispose();
  }

  /// Interpolates between [start] and [end] using a fixed number of steps.
  List<LatLng> interpolateCoordinates(
    LatLng start,
    LatLng end, {
    int steps = 10,
  }) {
    final interpolatedPoints = <LatLng>[];
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final latitude = start.latitude + (end.latitude - start.latitude) * t;
      final longitude = start.longitude + (end.longitude - start.longitude) * t;
      interpolatedPoints.add(LatLng(latitude, longitude));
    }
    return interpolatedPoints;
  }

  /// Update the polyline based on the current animation value and the latest state.
  void _updatePolylines() {
    if (_latestState is RecordWalkRecording &&
        (_latestState! as RecordWalkRecording).coordinates.length > 1) {
      final state = _latestState! as RecordWalkRecording;
      final confirmed = state.previousCoordinates;
      final lastConfirmed = confirmed.last;
      final newPoint = state.coordinates.last;
      const steps = 10;

      // Get all interpolated points between lastConfirmed and newPoint.
      final allInterpolated = interpolateCoordinates(lastConfirmed, newPoint);

      // Determine how many steps to reveal based on _animation.value.
      final currentStep = (_animation.value * steps).ceil().clamp(0, steps);
      final animatedSegment = allInterpolated.take(currentStep).toList();

      // Combine confirmed points with the animated segment.
      final polylinePoints = [
        ...confirmed,
        ...animatedSegment,
      ];

      // Update the notifier.
      _polylineNotifier.value = {
        Polyline(
          polylineId: PolylineId('recording_walk'),
          points: polylinePoints,
          color: context.colorScheme.primary,
          width: 5,
        ),
      };
    } else if (_latestState != null) {
      // Not recording or not enough points: use the full coordinate list.
      _polylineNotifier.value = {
        Polyline(
          polylineId: PolylineId('recording_walk'),
          points: _latestState!.coordinates,
          color: context.colorScheme.primary,
          width: 5,
        ),
      };
    }
  }

  /// Starts (or restarts) the segment animation.
  void _startSegmentAnimation(RecordWalkRecording state) {
    _controller.reset();
    _controller.forward();
    _updatePolylines(); // Ensure an immediate update.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordWalkCubit, RecordWalkState>(
      listenWhen: (previous, current) =>
          previous.coordinates != current.coordinates,
      listener: (context, state) {
        _latestState = state;
        if (state is RecordWalkRecording &&
            state.coordinates.length > state.previousCoordinates.length) {
          // A new coordinate has been added—animate the new segment.
          _startSegmentAnimation(state);
        } else {
          // Otherwise, update immediately.
          _updatePolylines();
        }
      },
      child: AdaptiveScaffold(
        title: const Text('Record Walk'),
        child: Stack(
          children: [
            // The PlatformMap is wrapped in a ValueListenableBuilder so that only its
            // polyline overlay updates when _polylineNotifier changes.
            ValueListenableBuilder<Set<Polyline>>(
              valueListenable: _polylineNotifier,
              builder: (context, polylines, child) {
                return PlatformMap(
                  // Use a constant key to keep the underlying platform view alive.
                  key: const ValueKey('platform_map'),
                  initialCameraPosition: CameraPosition(
                    target: (polylines.isNotEmpty)
                        ? polylines.first.points.last
                        : (_latestState?.coordinates.isNotEmpty == true
                            ? _latestState!.coordinates.last
                            : const LatLng(0, 0)),
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: false,
                  polylines: polylines,
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: BlocBuilder<RecordWalkCubit, RecordWalkState>(
                  builder: (context, state) {
                    return CupertinoButton.filled(
                      onPressed: () => state.isRecording
                          ? context.read<RecordWalkCubit>().finishRecording()
                          : context.read<RecordWalkCubit>().startRecording(),
                      child: switch (state) {
                        RecordWalkInitial() => const Text('Start recording'),
                        RecordWalkRecording() => const Text('Stop recording'),
                        RecordWalkFinishedRecording() =>
                          const Text('Finished recording'),
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

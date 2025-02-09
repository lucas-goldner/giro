import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/core/widgets/adaptive_scaffold.dart';
import 'package:giro/record_walk/cubit/record_walk_cubit.dart';
import 'package:giro/route_detail/screen/route_detail.dart';
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
  RecordWalkPageState createState() => RecordWalkPageState();
}

class RecordWalkPageState extends State<RecordWalk>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// A notifier that holds the current set of polylines.
  /// The PlatformMap will rebuild only its overlay when this changes.
  final ValueNotifier<Set<Polyline>> _polylineNotifier =
      ValueNotifier(const {});
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

  void _updatePolylines() {
    if (_latestState is RecordWalkRecording &&
        (_latestState! as RecordWalkRecording).coordinates.length > 1) {
      final state = _latestState! as RecordWalkRecording;
      final confirmed = state.previousCoordinates;
      final lastConfirmed = confirmed.last;
      final newPoint = state.coordinates.last;
      const steps = 10;

      final allInterpolated = interpolateCoordinates(lastConfirmed, newPoint);

      final currentStep = (_animation.value * steps).ceil().clamp(0, steps);
      final animatedSegment = allInterpolated.take(currentStep).toList();

      final polylinePoints = [
        ...confirmed,
        ...animatedSegment,
      ];

      _polylineNotifier.value = {
        Polyline(
          polylineId: PolylineId('recording_walk'),
          points: polylinePoints,
          color: context.colorScheme.primary,
          width: 5,
        ),
      };
    } else if (_latestState != null) {
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

  void _startSegmentAnimation(RecordWalkRecording state) {
    _controller
      ..reset()
      ..forward();
    _updatePolylines();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RecordWalkCubit, RecordWalkState>(
        listenWhen: (previous, current) =>
            previous.coordinates != current.coordinates,
        listener: (context, state) {
          _latestState = state;
          if (state is RecordWalkRecording &&
              state.coordinates.length > state.previousCoordinates.length) {
            _startSegmentAnimation(state);
          } else {
            _updatePolylines();
          }
        },
        child: AdaptiveScaffold(
          title: const Text('Record Walk'),
          child: Stack(
            children: [
              // The PlatformMap is wrapped in a ValueListenableBuilder
              // so that only its polyline overlay updates
              // when _polylineNotifier changes.
              ValueListenableBuilder<Set<Polyline>>(
                valueListenable: _polylineNotifier,
                builder: (context, polylines, child) {
                  return PlatformMap(
                    // Use a constant key to keep
                    // the underlying platform view alive
                    key: const ValueKey('platform_map'),
                    initialCameraPosition: CameraPosition(
                      target: (polylines.isNotEmpty)
                          ? polylines.first.points.isNotEmpty
                              ? polylines.first.points.last
                              : const LatLng(0, 0)
                          : (_latestState?.coordinates.isNotEmpty ?? false)
                              ? (_latestState?.coordinates ?? []).last
                              : const LatLng(0, 0),
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
                  child: BlocConsumer<RecordWalkCubit, RecordWalkState>(
                    listener: (context, state) {
                      final currentState = state;
                      final currentRoute = currentState.route;

                      if (currentState is RecordWalkFinishedRecording &&
                          currentRoute != null) {
                        context.read<WalkRoutesCubit>().addRoute(currentRoute);
                      }
                    },
                    builder: (context, state) => CupertinoButton.filled(
                      onPressed: () => switch (state) {
                        RecordWalkInitial() =>
                          context.read<RecordWalkCubit>().startRecording(),
                        RecordWalkRecording() =>
                          context.read<RecordWalkCubit>().finishRecording(),
                        RecordWalkFinishedRecording() =>
                          context.navigator.pushNamed(
                            RouteDetailPage.routeName,
                            arguments: state.route,
                          ),
                      },
                      child: switch (state) {
                        RecordWalkInitial() => const Text('Start recording'),
                        RecordWalkRecording() => const Text('Stop recording'),
                        RecordWalkFinishedRecording() =>
                          const Text('View finished recording'),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

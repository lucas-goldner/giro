import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
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

class RecordWalk extends StatelessWidget {
  const RecordWalk({super.key});

  List<LatLng> interpolateCoordinates(
    LatLng start,
    LatLng end, {
    int steps = 10,
  }) {
    final interpolatedPoints = <LatLng>[];

    for (var i = 0; i <= steps; i++) {
      final t = i / steps; // t goes from 0.0 to 1.0
      final latitude = start.latitude + (end.latitude - start.latitude) * t;
      final longitude = start.longitude + (end.longitude - start.longitude) * t;
      interpolatedPoints.add(LatLng(latitude, longitude));
    }

    return interpolatedPoints;
  }

  List<LatLng> pointsToDisplay(RecordWalkState recordWalkState) {
    if (recordWalkState.isRecording && recordWalkState.coordinates.length > 1) {
      final recordingState = recordWalkState as RecordWalkRecording;
      return [
        ...recordWalkState.previousCoordinates,
        ...interpolateCoordinates(
          recordingState.previousCoordinates.last,
          recordingState.coordinates.last,
        ),
      ];
    }

    if (recordWalkState.coordinates.length < 2) {
      return recordWalkState.coordinates;
    }

    return recordWalkState.coordinates;
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RecordWalkCubit, RecordWalkState>(
        builder: (context, recordWalkState) => AdaptiveScaffold(
          title: const Text('Record Walk'),
          child: Stack(
            children: [
              BlocBuilder<WalkRoutesCubit, WalkRoutesState>(
                builder: (context, walksState) => PlatformMap(
                  initialCameraPosition: CameraPosition(
                    target: walksState.routes.isNotEmpty
                        ? walksState.routes.first.coordinates.last
                        : const LatLng(0, 0).defaultCoordinates,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: false,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId('recording_walk'),
                      points: pointsToDisplay(recordWalkState),
                      color: context.colorScheme.primary,
                      width: 5,
                    ),
                  },
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: CupertinoButton.filled(
                    onPressed: () => recordWalkState.isRecording
                        ? context.read<RecordWalkCubit>().finishRecording()
                        : context.read<RecordWalkCubit>().startRecording(),
                    child: switch (recordWalkState) {
                      RecordWalkInitial() => const Text('Start recording'),
                      RecordWalkRecording() => const Text('Stop recording'),
                      RecordWalkFinishedRecording() =>
                        const Text('Finished recording'),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

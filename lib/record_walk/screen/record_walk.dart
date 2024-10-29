import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/core/widgets/adaptive_scaffold.dart';
import 'package:giro/record_walk/cubit/record_walk_cubit.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class RecordWalkPage extends StatelessWidget {
  const RecordWalkPage({super.key});
  static const String routeName = '/record_walk';

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => RecordWalkCubit(WalkRoutesRepoMmkvImpl()),
        child: const RecordWalk(),
      );
}

class RecordWalk extends StatelessWidget {
  const RecordWalk({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RecordWalkCubit, RecordWalkState>(
        builder: (context, state) {
          return AdaptiveScaffold(
            title: const Text('Record Walk'),
            child: Stack(
              children: [
                PlatformMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(48.962316599573725, 9.262961877486779),
                    zoom: 16,
                  ),
                  onTap: (location) => print('onTap: $location'),
                ),
                SafeArea(
                  child: Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: CupertinoButton.filled(
                      onPressed: () => state.isRecording
                          ? context.read<RecordWalkCubit>().finishRecording()
                          : context.read<RecordWalkCubit>().startRecording(),
                      child: switch (state) {
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
          );
        },
      );
}

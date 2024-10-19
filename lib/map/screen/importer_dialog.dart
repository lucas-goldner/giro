import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/core/repository/walk_routes_repo_impl.dart';
import 'package:giro/map/cubit/healthkit_cubit.dart';
import 'package:giro/map/repository/healthkit_repo_method_channel_impl.dart';

class ImporterDialogPage extends StatelessWidget {
  const ImporterDialogPage({super.key});
  static const String routeName = '/import';

  MaterialPageRoute<void> get route => MaterialPageRoute(
        builder: (_) => this,
      );

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<HealthkitCubit>(
            create: (context) => HealthkitCubit(
              HealthkitRepoMethodChannelImpl(),
            ),
          ),
          BlocProvider<WalkRoutesCubit>(
            create: (context) => WalkRoutesCubit(
              WalkRoutesRepoImpl(),
            ),
          ),
        ],
        child: const ImporterDialog(),
      );
}

class ImporterDialog extends StatefulWidget {
  const ImporterDialog({super.key});

  @override
  State<ImporterDialog> createState() => _ImporterDialogState();
}

class _ImporterDialogState extends State<ImporterDialog> {
  bool _hasLoaded = false;
  final List<WalkWorkout> _selectedWorkouts = [];

  Future<void> _loadWalks() async => context
      .read<HealthkitCubit>()
      .retrieveLastWalkingWorkouts()
      .then((_) => setState(() => _hasLoaded = true));

  Future<void> _saveWalks() async => Future.wait(
        _selectedWorkouts.map(
          (workout) =>
              context.read<WalkRoutesCubit>().retrieveRoutesForWorkout(workout),
        ),
      ).then((_) => reset());

  void reset() {
    setState(() => _hasLoaded = false);
    setState(_selectedWorkouts.clear);
  }

  void _onSelected(WalkWorkout workout) => setState(
        () => _selectedWorkouts.contains(workout)
            ? _selectedWorkouts.remove(workout)
            : _selectedWorkouts.add(workout),
      );

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Past workouts',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                CupertinoButton.filled(
                  onPressed: _hasLoaded ? _saveWalks : _loadWalks,
                  child: Text(_hasLoaded ? 'Save walks' : 'Import walks'),
                ),
              ],
            ),
          ),
          if (_hasLoaded) ...[
            const Divider(),
            Expanded(
              child: BlocBuilder<HealthkitCubit, HealthKitState>(
                builder: (context, state) {
                  final workouts = state.workouts;
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            workout.startDate.toLocalizedString(context),
                          ),
                          subtitle: Text(
                            workout.displayDuration(context),
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Checkbox.adaptive(
                            value: _selectedWorkouts.contains(workout),
                            onChanged: (_) => _onSelected(
                              workout,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      );
}

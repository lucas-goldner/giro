import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_workout.dart';
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
  late Future<void> _healthKitAuthorized;
  bool _hasLoaded = false;
  final List<WalkWorkout> _selectedWorkouts = [];

  Future<void> _loadWalks() async => context
      .read<HealthkitCubit>()
      .retrieveWorkoutsWithRoutes()
      .then((_) => setState(() => _hasLoaded = true));

  Future<void> _saveWalks() async {
    await context.read<WalkRoutesCubit>().fetchRoutes();

    // for (final workout in _selectedWorkouts) {
    //   context.read<WalkRoutesCubit>().addRoute(workout.toRoute());
    // }

    // setState(() {
    //   _hasLoaded = false;
    //   _selectedWorkouts.clear();
    // });
  }

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
  void initState() {
    _healthKitAuthorized = context.read<HealthkitCubit>().authorize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _healthKitAuthorized,
        builder: (context, snapshot) {
          return Column(
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
              const Divider(),
              Expanded(
                child: BlocBuilder<HealthkitCubit, HealthKitState>(
                  builder: (context, state) {
                    final workouts = state.workouts;

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!state.authorized) {
                      return const Text('Not authorized to use HealthKit');
                    }

                    if (_hasLoaded) {
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
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      );
}
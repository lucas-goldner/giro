import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_workout.dart';
import 'package:giro/design/shared/route_preview.dart';
import 'package:giro/design/sonic/sonic_theme.dart';
import 'package:giro/map/cubit/healthkit_cubit.dart';
import 'package:giro/map/repository/healthkit_repo.dart';

/// Item box: walks recorded by the watch (HealthKit), picked and saved as
/// stages.
class SonicImportPage extends StatelessWidget {
  const SonicImportPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => HealthkitCubit(context.read<HealthkitRepo>()),
    child: const _SonicImport(),
  );
}

class _SonicImport extends StatefulWidget {
  const _SonicImport();

  @override
  State<_SonicImport> createState() => _SonicImportState();
}

class _SonicImportState extends State<_SonicImport> {
  late final Future<void> _authorized = context
      .read<HealthkitCubit>()
      .authorize();
  final Set<WalkWorkout> _selected = {};
  bool _loaded = false;

  Future<void> _load() async {
    await context.read<HealthkitCubit>().retrieveWorkoutsWithRoutes();
    if (mounted) {
      setState(() => _loaded = true);
    }
  }

  void _save() {
    for (final workout in _selected) {
      context.read<WalkRoutesCubit>().addRoute(workout.toRoute());
    }
    setState(_selected.clear);
  }

  bool _imported(WalkWorkout workout) =>
      context.read<WalkRoutesCubit>().state.routes.any(
        (route) =>
            route.startDate.withoutMilliOrMicroSeconds ==
                workout.startDate.withoutMilliOrMicroSeconds &&
            route.endDate.withoutMilliOrMicroSeconds ==
                workout.endDate.withoutMilliOrMicroSeconds,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SonicTheme.navy,
    body: SonicPanel(
      slantedTop: false,
      fill: true,
      padding: EdgeInsets.zero,
      child: SafeArea(
        child: FutureBuilder<void>(
          future: _authorized,
          builder: (context, snapshot) =>
              BlocBuilder<HealthkitCubit, HealthKitState>(
                builder: (context, state) {
                  final waiting =
                      snapshot.connectionState != ConnectionState.done;
                  final workouts = state.workouts;
                  final pending = workouts.where((w) => !_imported(w)).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SonicRingChip(
                                  onTap: context.navigator.pop,
                                  child: const Text('◀  BACK'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'ITEM BOX · HEALTH',
                                      style: SonicTheme.label.copyWith(
                                        color: SonicTheme.gold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const SonicHudText('IMPORT WALKS', size: 34),
                            const SizedBox(height: 6),
                            const Text(
                              'Walks recorded by your watch become stages. '
                              'Only routes from supported watches carry a map.',
                              style: SonicTheme.body,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: waiting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: SonicTheme.gold,
                                ),
                              )
                            : !state.authorized
                            ? const _Message(
                                'HEALTH ACCESS DENIED',
                                'Allow Giro to read workouts in the Health '
                                    'app, then come back.',
                              )
                            : !_loaded
                            ? _Message(
                                'ITEM BOX CLOSED',
                                'Load your recent walks to pick the ones '
                                    'worth a stage.',
                                action: SonicButton(
                                  label: 'Load workouts',
                                  caption: 'From Health',
                                  color: SonicTheme.gold,
                                  shadow: SonicTheme.goldDeep,
                                  height: 56,
                                  onTap: _load,
                                ),
                              )
                            : workouts.isEmpty
                            ? const _Message(
                                'NOTHING HERE',
                                'No walks found in Health.',
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  6,
                                  14,
                                  100,
                                ),
                                itemCount: workouts.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final workout = workouts[index];
                                  final imported = _imported(workout);
                                  return _WorkoutCard(
                                    workout: workout,
                                    imported: imported,
                                    selected: _selected.contains(workout),
                                    onTap: imported
                                        ? null
                                        : () => setState(
                                            () => _selected.contains(workout)
                                                ? _selected.remove(workout)
                                                : _selected.add(workout),
                                          ),
                                  );
                                },
                              ),
                      ),
                      if (_loaded && pending > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                          child: SonicButton(
                            label: _selected.isEmpty
                                ? 'Pick walks'
                                : 'Save ${_selected.length} '
                                      'walk${_selected.length == 1 ? '' : 's'}',
                            caption: _selected.isEmpty
                                ? 'Tap a workout to select it'
                                : 'Add as stages',
                            semanticsLabel: 'Save walks',
                            color: _selected.isEmpty
                                ? SonicTheme.blue
                                : SonicTheme.red,
                            shadow: _selected.isEmpty
                                ? SonicTheme.blueDeep
                                : SonicTheme.redDeep,
                            height: 56,
                            onTap: _selected.isEmpty ? () {} : _save,
                          ),
                        ),
                    ],
                  );
                },
              ),
        ),
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.title, this.body, {this.action});

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: SonicTheme.label),
        const SizedBox(height: 4),
        Text(body, style: SonicTheme.body),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.imported,
    required this.selected,
    required this.onTap,
  });

  final WalkWorkout workout;
  final bool imported;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = workout.startDate.toLocalizedString(context);
    final km = (workout.totalDistance / 1000).toStringAsFixed(1);
    return Semantics(
      button: !imported,
      selected: selected,
      label: imported ? '$date, already a stage' : '$date workout',
      child: ExcludeSemantics(
        child: Opacity(
          opacity: imported ? 0.55 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A3CAB), Color(0xFF0F2A84)],
                  ),
                  border: Border.all(
                    color: selected ? SonicTheme.gold : SonicTheme.outline,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF061240), offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 56,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: workout.routes.length > 1
                            ? RoutePreview(
                                points: workout.routes,
                                color: SonicTheme.sky,
                                background: SonicTheme.navyDeep,
                              )
                            : const ColoredBox(
                                color: SonicTheme.navyDeep,
                                child: Icon(
                                  Icons.watch_rounded,
                                  color: SonicTheme.sky,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: SonicTheme.font,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: SonicTheme.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.displayDuration(context)} · '
                            '$km km'
                            '${imported ? ' · STAGE CLEARED' : ''}',
                            style: SonicTheme.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (imported)
                      const Icon(Icons.check_rounded, color: SonicTheme.gold)
                    else
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? SonicTheme.gold
                              : Colors.transparent,
                          border: Border.all(color: SonicTheme.gold, width: 3),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: SonicTheme.navy,
                              )
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

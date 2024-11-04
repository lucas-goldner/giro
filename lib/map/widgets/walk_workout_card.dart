import 'package:flutter/material.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_workout.dart';

class WalkWorkoutCard extends StatelessWidget {
  const WalkWorkoutCard({
    required this.workout,
    required this.selectedWorkouts,
    required this.onSelected,
    required this.importedAlready,
    super.key,
  });

  final WalkWorkout workout;
  final List<WalkWorkout> selectedWorkouts;
  final void Function(WalkWorkout) onSelected;
  final bool importedAlready;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(
            workout.startDate.toLocalizedString(context),
          ),
          subtitle: Row(
            children: [
              Text(
                workout.displayDuration(context),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: importedAlready ? Colors.blue : Colors.green,
            child: const Icon(
              Icons.directions_walk,
              color: Colors.white,
            ),
          ),
          trailing: Checkbox.adaptive(
            value: selectedWorkouts.contains(workout),
            onChanged: (_) => onSelected(
              workout,
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_workout.dart';

class WalkWorkoutCard extends StatelessWidget {
  const WalkWorkoutCard({
    required this.workout,
    required this.selectedWorkouts,
    required this.onSelected,
    super.key,
  });

  final WalkWorkout workout;
  final List<WalkWorkout> selectedWorkouts;
  final void Function(WalkWorkout) onSelected;

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
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(
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

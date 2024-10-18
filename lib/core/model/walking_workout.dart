enum HKWorkoutEventType {
  pause(1),
  resume(2),
  lap(3),
  marker(4),
  motionPaused(5),
  motionResumed(6),
  segment(7),
  pauseOrResumeRequest(8);

  const HKWorkoutEventType(this.value);
  final int value;
}

class WalkingWorkout {
  WalkingWorkout({
    required this.startDate,
    required this.endDate,
    this.workoutEvents,
    this.workoutActivities,
    this.duration = 0,
    this.totalEnergyBurned,
    this.totalDistance,
    this.metadata,
  });

  final DateTime startDate;
  final DateTime endDate;
  final List<HKWorkoutEvent>? workoutEvents;
  final List<HKWorkoutActivity>? workoutActivities;
  final double duration;
  final HKQuantity? totalEnergyBurned;
  final HKQuantity? totalDistance;
  final Map<String, dynamic>? metadata;
}

class HKQuantity {
  HKQuantity({
    required this.value,
    required this.unit,
  });
  final double value;
  final String unit;
}

class HKWorkoutEvent {
  HKWorkoutEvent({
    required this.type,
    required this.startDate,
    this.endDate,
    this.metadata,
  });
  final HKWorkoutEventType type;
  final DateTime startDate;
  final DateTime? endDate;
  final Map<String, dynamic>? metadata;
}

class HKWorkoutActivity {
  HKWorkoutActivity({
    required this.startDate,
    required this.endDate,
    this.metadata,
  });

  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? metadata;
}

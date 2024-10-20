part of 'healthkit_cubit.dart';

sealed class HealthKitState extends Equatable {
  const HealthKitState({required this.authorized, this.workouts = const []})
      : super();
  final bool authorized;
  final List<WalkWorkout> workouts;

  @override
  List<Object?> get props => [
        authorized,
        workouts,
      ];
}

final class HealthKitStateUninitialized extends HealthKitState {
  const HealthKitStateUninitialized() : super(authorized: false);
}

final class HealthKitStateUnauthorized extends HealthKitState {
  const HealthKitStateUnauthorized() : super(authorized: false);
}

final class HealthKitStateLoadingWorkout extends HealthKitState {
  const HealthKitStateLoadingWorkout()
      : super(
          authorized: true,
          workouts: const [],
        );
}

final class HealthKitStateAuthorized extends HealthKitState {
  const HealthKitStateAuthorized({required super.workouts})
      : super(
          authorized: true,
        );
}

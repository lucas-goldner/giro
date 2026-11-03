part of 'healthkit_cubit.dart';

sealed class HealthKitState extends Equatable {
  const HealthKitState({required this.authorized, this.workouts = const []})
    : super();
  final bool authorized;
  final List<WalkWorkout> workouts;

  @override
  List<Object?> get props => [authorized, workouts];
}

final class HealthKitStateUninitialized extends HealthKitState {
  const HealthKitStateUninitialized() : super(authorized: false);
}

final class HealthKitStateUnauthorized extends HealthKitState {
  const HealthKitStateUnauthorized() : super(authorized: false);
}

final class HealthKitStateLoadingWorkout extends HealthKitState {
  const HealthKitStateLoadingWorkout()
    : super(authorized: true, workouts: const []);
}

/// Paging through the complete Health history; [fetched] grows as pages
/// arrive.
final class HealthKitStateImporting extends HealthKitState {
  const HealthKitStateImporting({
    required super.workouts,
    required this.fetched,
  }) : super(authorized: true);

  final int fetched;

  @override
  List<Object?> get props => [...super.props, fetched];
}

final class HealthKitStateAuthorized extends HealthKitState {
  const HealthKitStateAuthorized({required super.workouts})
    : super(authorized: true);
}

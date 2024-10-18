part of 'healthkit_cubit.dart';

sealed class HealthKitState extends Equatable {
  const HealthKitState({required this.authorized});
  final bool authorized;

  @override
  List<Object?> get props => [authorized];
}

final class HealthKitStateUninitialized extends HealthKitState {
  const HealthKitStateUninitialized() : super(authorized: false);
}

final class HealthKitStateAuthorized extends HealthKitState {
  const HealthKitStateAuthorized() : super(authorized: true);
}

final class HealthKitStateUnauthorized extends HealthKitState {
  const HealthKitStateUnauthorized() : super(authorized: false);
}

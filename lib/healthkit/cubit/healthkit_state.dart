part of 'healthkit_cubit.dart';

sealed class HealthKitState {
  HealthKitState({required this.authorized});
  final bool authorized;
}

final class HealthKitStateUninitialized extends HealthKitState {
  HealthKitStateUninitialized() : super(authorized: false);
}

final class HealthKitStateAuthorized extends HealthKitState {
  HealthKitStateAuthorized() : super(authorized: true);
}

final class HealthKitStateUnauthorized extends HealthKitState {
  HealthKitStateUnauthorized() : super(authorized: false);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/healthkit/repository/healthkit_repo.dart';

part 'healthkit_state.dart';

class HealthkitCubit extends Cubit<HealthKitState> {
  HealthkitCubit(this._healthkitRepo) : super(HealthKitStateUninitialized());
  final HealthkitRepo _healthkitRepo;

  Future<void> authorize() async {
    final authorized = await _healthkitRepo.requestAuthorization();
    emit(
      authorized ? HealthKitStateAuthorized() : HealthKitStateUnauthorized(),
    );
  }

  bool get isAuthorized => state.authorized;
}

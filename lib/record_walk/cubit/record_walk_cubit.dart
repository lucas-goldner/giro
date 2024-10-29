import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

part 'record_walk_state.dart';

class RecordWalkCubit extends Cubit<RecordWalkState> {
  RecordWalkCubit(this._walkRoutesRepo) : super(RecordWalkInitial());

  final WalkRoutesRepo _walkRoutesRepo;

  void startRecording() {
    final recordingState = RecordWalkRecording(
      coordinates: [],
      startDate: DateTime.now(),
      onTimerTick: (elapsedTime) {
        // addCoordinate();
      },
    )..startTimer();
    emit(recordingState);
  }

  void addCoordinate(LatLng coordinate) {
    final newCoordinates = List<LatLng>.from(state.coordinates);
    emit(
      RecordWalkRecording(
        coordinates: [...newCoordinates, coordinate],
        startDate: state.startDate ?? DateTime.now(),
        onTimerTick: (state as RecordWalkRecording).onTimerTick,
      ),
    );
  }

  void finishRecording() {
    if (state is RecordWalkRecording) {
      final recordingState = state as RecordWalkRecording..stopTimer();

      final route = WalkRoute(
        coordinates: state.coordinates,
        startDate: state.startDate ?? DateTime.now(),
        endDate: DateTime.now(),
      );

      _walkRoutesRepo.addRoute(route);

      emit(
        RecordWalkFinishedRecording(
          coordinates: recordingState.coordinates,
          route: route,
        ),
      );
    } else {
      emit(RecordWalkInitial());
    }
  }
}

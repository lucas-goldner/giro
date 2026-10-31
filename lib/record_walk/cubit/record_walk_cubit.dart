import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

part 'record_walk_state.dart';

class RecordWalkCubit extends Cubit<RecordWalkState> {
  RecordWalkCubit(this._walkRoutesRepo) : super(RecordWalkInitial());

  final WalkRoutesRepo _walkRoutesRepo;

  /// Samples the location while recording. Owned by the cubit (not the
  /// state) so it survives the state copies made by [addCoordinate] and is
  /// reliably cancelled by [finishRecording] and [close].
  Timer? _timer;

  Future<LatLng> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final newPermission = await Geolocator.requestPermission();
      if (newPermission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  void startRecording() {
    emit(
      RecordWalkRecording(
        coordinates: [],
        previousCoordinates: [],
        startDate: DateTime.now(),
      ),
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final coordinates = await _getCurrentLocation();
      addCoordinate(coordinates);
    });
  }

  void addCoordinate(LatLng newCoordinate) {
    if (state is RecordWalkRecording) {
      final currentCoordinates = List<LatLng>.from(state.coordinates);
      emit(
        RecordWalkRecording(
          coordinates: [...currentCoordinates, newCoordinate],
          previousCoordinates: [...currentCoordinates],
          startDate: state.startDate ?? DateTime.now(),
        ),
      );
    }
  }

  void finishRecording() {
    if (state is RecordWalkRecording) {
      _timer?.cancel();
      _timer = null;

      final route = WalkRoute(
        coordinates: state.coordinates,
        startDate: state.startDate ?? DateTime.now(),
        endDate: DateTime.now(),
      );

      _walkRoutesRepo.addRoute(route);

      emit(
        RecordWalkFinishedRecording(
          coordinates: state.coordinates,
          route: route,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

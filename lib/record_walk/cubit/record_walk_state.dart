part of 'record_walk_cubit.dart';

sealed class RecordWalkState {
  RecordWalkState({
    required this.coordinates,
    required this.startDate,
    this.route,
  });

  List<LatLng> coordinates = <LatLng>[];
  DateTime? startDate;
  WalkRoute? route;

  bool get isRecording => this is RecordWalkRecording;
  bool get isFinished => this is RecordWalkFinishedRecording;
}

class RecordWalkInitial extends RecordWalkState {
  RecordWalkInitial()
      : super(
          coordinates: const [],
          startDate: null,
        );
}

class RecordWalkRecording extends RecordWalkState {
  RecordWalkRecording({
    required super.coordinates,
    required super.startDate,
    required this.previousCoordinates,
  });

  List<LatLng> previousCoordinates;
}

class RecordWalkFinishedRecording extends RecordWalkState {
  RecordWalkFinishedRecording({
    required super.coordinates,
    required super.route,
  }) : super(startDate: null);
}

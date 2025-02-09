part of 'record_walk_cubit.dart';

typedef TimerCallback = void Function(int elapsedTime);

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
    required this.onTimerTick,
  }) : _elapsedTime = 0;

  List<LatLng> previousCoordinates;
  final TimerCallback onTimerTick;
  Timer? _timer;
  int _elapsedTime;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _elapsedTime += 5;
      onTimerTick(_elapsedTime);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _elapsedTime = 0;
  }
}

class RecordWalkFinishedRecording extends RecordWalkState {
  RecordWalkFinishedRecording({
    required super.coordinates,
    required super.route,
  }) : super(startDate: null);
}

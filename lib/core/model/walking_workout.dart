import 'package:equatable/equatable.dart';

class WalkingWorkout extends Equatable {
  const WalkingWorkout({
    required this.activityType,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalDistance,
    required this.totalEnergyBurned,
  });

  factory WalkingWorkout.fromJson(Map<String, dynamic> json) {
    return WalkingWorkout(
      activityType: json['activityType'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        ((json['startDate'] as num) * 1000).round(),
        isUtc: true,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        ((json['endDate'] as num) * 1000).round(),
        isUtc: true,
      ),
      duration: (json['duration'] as num).toDouble(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalEnergyBurned: (json['totalEnergyBurned'] as num).toDouble(),
    );
  }

  final int activityType;
  final DateTime startDate;
  final DateTime endDate;
  final double duration;
  final double totalDistance;
  final double totalEnergyBurned;

  @override
  List<Object?> get props => [
        activityType,
        startDate,
        endDate,
        duration,
        totalDistance,
        totalEnergyBurned,
      ];
}

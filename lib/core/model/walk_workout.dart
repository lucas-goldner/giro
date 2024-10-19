import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:giro/core/extensions.dart';

class WalkWorkout extends Equatable {
  const WalkWorkout({
    required this.activityType,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalDistance,
    required this.totalEnergyBurned,
  });

  factory WalkWorkout.fromJson(Map<String, dynamic> json) {
    return WalkWorkout(
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

  String get id {
    final dataString = '''
$activityType${startDate.millisecondsSinceEpoch}${endDate.millisecondsSinceEpoch}$duration$totalDistance$totalEnergyBurned
''';
    var hash = 0;
    for (final codeUnit in dataString.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  final int activityType;
  final DateTime startDate;
  final DateTime endDate;
  final double duration;
  final double totalDistance;
  final double totalEnergyBurned;

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'startDate': startDate.millisecondsSinceEpoch / 1000,
      'endDate': endDate.millisecondsSinceEpoch / 1000,
      'duration': duration,
      'totalDistance': totalDistance,
      'totalEnergyBurned': totalEnergyBurned,
    };
  }

  String displayDuration(BuildContext context) =>
      duration.toMinutesDuration().toLocalizedString(context);

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

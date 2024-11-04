import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

const _coordinatesForEvery5Seconds = 5;

class WalkRoute extends Equatable {
  const WalkRoute({
    required this.coordinates,
    required this.startDate,
    required this.endDate,
  });

  factory WalkRoute.fromJson(Map<String, dynamic> json) {
    final coordinates = (json['routes'] as List<dynamic>)
        .map(
          (coordinate) => LatLng(
            coordinate['latitude'] as double,
            coordinate['longitude'] as double,
          ),
        )
        .toList();

    return WalkRoute(
      coordinates: coordinates,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        ((json['startDate'] as num) * 1000).round(),
        isUtc: true,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        ((json['endDate'] as num) * 1000).round(),
        isUtc: true,
      ),
    );
  }

  String get id {
    final dataString = '''
${startDate.millisecondsSinceEpoch}${endDate.millisecondsSinceEpoch}${coordinates.length}
''';
    var hash = 0;
    for (final codeUnit in dataString.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  final List<LatLng> coordinates;
  final DateTime startDate;
  final DateTime endDate;
  Duration get duration => endDate.difference(startDate);
  int get durationInMinutes => endDate.difference(startDate).inMinutes;

  List<LatLng> get shortenedCoordinates {
    final totalDurationInSeconds = duration.inSeconds;

    final expectedPoints =
        totalDurationInSeconds ~/ _coordinatesForEvery5Seconds;

    if (coordinates.length <= expectedPoints || expectedPoints < 2) {
      return coordinates;
    }

    final totalCoordinates = coordinates.length;
    final result = <LatLng>[];

    // For each expected point, compute the corresponding index in coordinates
    for (var i = 0; i < expectedPoints; i++) {
      final index = (i * totalCoordinates) ~/ expectedPoints;
      result.add(coordinates[index]);
    }

    return result;
  }

  Color get color =>
      Color((int.parse(id) + _coordinatesHash) & 0xFFFFFFFF).withOpacity(0.8);
  int get _coordinatesHash {
    var hash = 0;
    for (var i = 0; i < min(5, coordinates.length); i++) {
      hash = hash * 31 +
          coordinates[i].latitude.hashCode +
          coordinates[i].longitude.hashCode;
    }

    return hash;
  }

  Map<String, dynamic> toJson() {
    return {
      'routes': coordinates
          .map(
            (point) => {
              'latitude': point.latitude,
              'longitude': point.longitude,
            },
          )
          .toList(),
      'startDate': startDate.millisecondsSinceEpoch ~/ 1000,
      'endDate': endDate.millisecondsSinceEpoch ~/ 1000,
    };
  }

  @override
  List<Object?> get props => [
        coordinates,
        startDate,
        endDate,
      ];
}

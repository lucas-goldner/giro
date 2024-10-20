import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class WalkRoute {
  WalkRoute({
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
}

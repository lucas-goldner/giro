import 'package:equatable/equatable.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class POI extends Equatable {
  const POI({
    required this.name,
    required this.coordinates,
    required this.createdAt,
  });

  factory POI.fromJson(Map<String, dynamic> json) => POI(
        name: json['name'] as String,
        coordinates: LatLng(
          json['coordinates']['latitude'] as double,
          json['coordinates']['longitude'] as double,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          ((json['createdAt'] as num) * 1000).round(),
          isUtc: true,
        ),
      );

  String get id {
    final dataString = '''
$name${coordinates.latitude}${coordinates.longitude}
''';
    var hash = 0;
    for (final codeUnit in dataString.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  final String name;
  final LatLng coordinates;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        coordinates,
        createdAt,
      ];
}

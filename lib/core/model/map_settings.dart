import 'package:equatable/equatable.dart';

/// User-tunable map appearance, persisted by `MapSettingsRepo`.
class MapSettings extends Equatable {
  const MapSettings({
    this.trailWidth = defaultTrailWidth,
    this.revealRadiusMeters = defaultRevealRadius,
    this.mapDownloadPrompted = false,
  });

  factory MapSettings.fromJson(Map<String, dynamic> json) => MapSettings(
    trailWidth: (json['trailWidth'] as num?)?.toDouble() ?? defaultTrailWidth,
    revealRadiusMeters:
        (json['revealRadiusMeters'] as num?)?.toDouble() ?? defaultRevealRadius,
    mapDownloadPrompted: json['mapDownloadPrompted'] as bool? ?? false,
  );

  static const defaultTrailWidth = 9.0;
  static const minTrailWidth = 3.0;
  static const maxTrailWidth = 24.0;
  static const defaultRevealRadius = 90.0;
  static const minRevealRadius = 30.0;
  static const maxRevealRadius = 400.0;

  /// Width of a walk line in logical pixels.
  final double trailWidth;

  /// How far around a walk the fog of war is lifted, in metres.
  final double revealRadiusMeters;

  /// Whether the first-run "download your area" screen was shown.
  final bool mapDownloadPrompted;

  /// The soft glow under a walk line.
  double get glowWidth => trailWidth * 2.6;

  /// Spots lift the fog a little less than walks.
  double get spotRadiusMeters => revealRadiusMeters * 0.8;

  MapSettings copyWith({
    double? trailWidth,
    double? revealRadiusMeters,
    bool? mapDownloadPrompted,
  }) => MapSettings(
    trailWidth: trailWidth ?? this.trailWidth,
    revealRadiusMeters: revealRadiusMeters ?? this.revealRadiusMeters,
    mapDownloadPrompted: mapDownloadPrompted ?? this.mapDownloadPrompted,
  );

  Map<String, dynamic> toJson() => {
    'trailWidth': trailWidth,
    'revealRadiusMeters': revealRadiusMeters,
    'mapDownloadPrompted': mapDownloadPrompted,
  };

  @override
  List<Object?> get props => [
    trailWidth,
    revealRadiusMeters,
    mapDownloadPrompted,
  ];
}

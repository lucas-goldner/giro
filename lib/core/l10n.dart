import 'package:flutter/widgets.dart';
import 'package:giro/generated/app_localizations.dart';
import 'package:intl/intl.dart';

export 'package:giro/generated/app_localizations.dart';

/// Localized strings and locale-aware number formats.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _locale => Localizations.localeOf(this).toString();

  /// Kilometres with one decimal in the locale's digits and separator
  /// ("1868.0", "1868,0").
  String km(double meters) =>
      NumberFormat('0.0', _locale).format(meters / 1000);

  /// "5.8 km" or "640 m".
  String distance(double meters) => meters >= 1000
      ? l10n.distanceKm(km(meters))
      : l10n.distanceM(meters.round());

  /// "1h 32m" or "44m" in the locale's words.
  String walkDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0
        ? l10n.durationHoursMinutes(hours, minutes.toString().padLeft(2, '0'))
        : l10n.durationMinutes(minutes);
  }
}

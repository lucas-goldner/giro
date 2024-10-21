import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

extension BuildContextExtensions on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  NavigatorState get navigator => Navigator.of(this);
  Size sizeOf() => MediaQuery.sizeOf(this);
  String get languageCode => Localizations.localeOf(this).languageCode;
}

extension DateTimeExtension on DateTime {
  String toLocalizedString(BuildContext context) => DateFormat.yMMMMEEEEd(
        context.languageCode,
      ).format(this);
}

extension DoubleExtension on double {
  Duration toMinutesDuration() => Duration(minutes: toInt() ~/ 60);
}

extension DurationExtension on Duration {
  String toLocalizedString(BuildContext context) => pretty(
        delimiter: ' ',
        spacer: '',
        abbreviated: true,
        tersity: DurationTersity.minute,
        locale: DurationLocale.fromLanguageCode(context.languageCode) ??
            const EnglishDurationLocale(),
      );
}

extension LatLngExtension on LatLng {
  Coords toCoords() => Coords(latitude, longitude);
}

import 'package:flutter/material.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/redesign/design_variant.dart';

/// Tokens shared by the "Clean" screens. Everything leans on the system
/// font, near-black text, iOS grouped grey and hairlines; the single green
/// is reserved for the primary action and route lines.
abstract final class CleanTheme {
  static RedesignPalette get palette => DesignVariant.clean.palette;

  static const Color hairline = Color(0xFFE5E5EA);
  static const Color fill = Color(0xFFF2F2F7);
  static const Color destructive = Color(0xFFFF3B30);

  static const TextStyle largeTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.1,
  );
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  static const TextStyle body = TextStyle(fontSize: 16, height: 1.3);
  static const TextStyle headline = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle footnote = TextStyle(fontSize: 13, height: 1.3);
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );
  static const TextStyle stat = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1,
  );

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// "Wed, Oct 28"
  static String shortDate(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, '
      '${_months[date.month - 1].substring(0, 3)} ${date.day}';

  /// "October 2026"
  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// "Wednesday, Oct 28 · 7:30 – 8:25 AM" (the period is repeated only
  /// when start and end fall on different sides of noon).
  static String dateAndTimeRange(WalkRoute route) {
    final start = route.startDate.toLocal();
    final end = route.endDate.toLocal();
    final samePeriod = (start.hour < 12) == (end.hour < 12);
    return '${_fullWeekdays[start.weekday - 1]}, '
        '${_months[start.month - 1].substring(0, 3)} ${start.day} · '
        '${_clock(start, withPeriod: !samePeriod)} – ${_clock(end)}';
  }

  static const List<String> _fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String _clock(DateTime local, {bool withPeriod = true}) {
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = withPeriod ? (local.hour < 12 ? ' AM' : ' PM') : '';
    return '$hour:$minute$period';
  }
}

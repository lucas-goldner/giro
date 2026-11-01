import 'package:flutter/material.dart';

/// Redesign proposals for the app shell (home + walks list).
///
/// Selected at start-up (the web preview reads `?design=journal|glass|blocks`);
/// `null` keeps the current screens.
enum DesignVariant {
  /// Warm, editorial: cream surfaces, forest green, terracotta accent.
  journal,

  /// Dark iOS glass: frosted panels over the map, one electric accent.
  glass,

  /// Playful dashboard: colour-block stat tiles and a 2x2 action grid.
  blocks,

  /// iOS-native and quiet: white sheet over the map, round icon actions,
  /// hairline lists, one calm green. Modelled on Apple Maps, komoot and
  /// Gentler Streak.
  clean,

  /// Swiss typographic: monochrome, big numerals, hairline rules, one red.
  swiss,

  /// Material You: seed-tinted pastel surfaces, large radii, tonal chips.
  tonal,

  /// Outdoor: sand paper with faint contour lines, forest green, pills.
  outdoor,

  /// Mono: pure black, thin type, hairlines, cyan only on the route.
  mono,

  /// Zenly: gradient-tinted map, giant lowercase title, black cards and
  /// square buttons with gradient icons.
  zenly,

  /// Sport: Nike Run Club. White, bold title with text tabs, faded map and
  /// one huge volt-yellow START circle.
  sport;

  static DesignVariant? current;

  static DesignVariant? fromName(String? name) =>
      values.where((variant) => variant.name == name).firstOrNull;

  RedesignPalette get palette => switch (this) {
    DesignVariant.journal => const RedesignPalette(
      background: Color(0xFFF6F1E7),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF2F5D50),
      accent: Color(0xFFD9703E),
      ink: Color(0xFF1E1E1E),
      muted: Color(0xFF7A776F),
      radius: 22,
      brightness: Brightness.light,
    ),
    DesignVariant.glass => const RedesignPalette(
      background: Color(0xFF0F1115),
      surface: Color(0xFF1A1D24),
      primary: Color(0xFF3D8BFF),
      accent: Color(0xFF3D8BFF),
      ink: Color(0xFFF5F7FA),
      muted: Color(0xFF8B93A1),
      radius: 18,
      brightness: Brightness.dark,
    ),
    DesignVariant.clean => const RedesignPalette(
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF2F2F7),
      primary: Color(0xFF1F8A5B),
      accent: Color(0xFF1F8A5B),
      ink: Color(0xFF111111),
      muted: Color(0xFF8A8A8E),
      radius: 14,
      brightness: Brightness.light,
    ),
    DesignVariant.swiss => const RedesignPalette(
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF111111),
      accent: Color(0xFFE10600),
      ink: Color(0xFF111111),
      muted: Color(0xFF6E6E6E),
      radius: 0,
      brightness: Brightness.light,
      listStyle: RedesignListStyle.rows,
    ),
    DesignVariant.tonal => const RedesignPalette(
      background: Color(0xFFF6F2FA),
      surface: Color(0xFFECE6F2),
      primary: Color(0xFF5B4B9E),
      accent: Color(0xFF5B4B9E),
      ink: Color(0xFF1C1B22),
      muted: Color(0xFF6F6B79),
      radius: 28,
      brightness: Brightness.light,
    ),
    DesignVariant.outdoor => const RedesignPalette(
      background: Color(0xFFF3EEE3),
      surface: Color(0xFFFFFDF8),
      primary: Color(0xFF1F4D3A),
      accent: Color(0xFF1F4D3A),
      ink: Color(0xFF1E2A24),
      muted: Color(0xFF7B8178),
      radius: 20,
      brightness: Brightness.light,
    ),
    DesignVariant.mono => const RedesignPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF000000),
      primary: Color(0xFF4DE1D2),
      accent: Color(0xFF4DE1D2),
      ink: Color(0xFFF2F2F2),
      muted: Color(0xFF8C8C8C),
      radius: 0,
      brightness: Brightness.dark,
      listStyle: RedesignListStyle.rows,
    ),
    DesignVariant.zenly => const RedesignPalette(
      background: Color(0xFF0E0E0E),
      surface: Color(0xFF1C1C1E),
      primary: Color(0xFF7CF7C4),
      accent: Color(0xFFFF8FB1),
      ink: Color(0xFFFFFFFF),
      muted: Color(0xFF9A9AA3),
      radius: 20,
      brightness: Brightness.dark,
    ),
    DesignVariant.sport => const RedesignPalette(
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      primary: Color(0xFF111111),
      accent: Color(0xFFF5E400),
      ink: Color(0xFF111111),
      muted: Color(0xFF757575),
      radius: 12,
      brightness: Brightness.light,
    ),
    DesignVariant.blocks => const RedesignPalette(
      background: Color(0xFFFFF8E7),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF2EC4B6),
      accent: Color(0xFFFF6B6B),
      ink: Color(0xFF1B1B2F),
      muted: Color(0xFF6F6F80),
      radius: 26,
      brightness: Brightness.light,
    ),
  };
}

/// How the walks list separates entries.
enum RedesignListStyle {
  /// Rounded surface-coloured cards.
  cards,

  /// Plain rows on the background with hairline dividers.
  rows,
}

class RedesignPalette {
  const RedesignPalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.ink,
    required this.muted,
    required this.radius,
    required this.brightness,
    this.listStyle = RedesignListStyle.cards,
  });

  final RedesignListStyle listStyle;

  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color ink;
  final Color muted;
  final double radius;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sonic Generations HUD language: skewed italic condensed type with a
/// drop outline, Sonic blue on navy, gold accents, diagonal speed stripes,
/// chevron buttons with a hard shadow, and ranks.
abstract final class SonicTheme {
  static const Color blue = Color(0xFF1B5BFF);
  static const Color blueDeep = Color(0xFF0A2F9C);
  static const Color navy = Color(0xFF0A1D58);
  static const Color navyDeep = Color(0xFF071544);
  static const Color sky = Color(0xFF5FC8FF);
  static const Color gold = Color(0xFFFFC400);
  static const Color goldDeep = Color(0xFF8A5A00);
  static const Color red = Color(0xFFEA3A3A);
  static const Color redDeep = Color(0xFF8F1A1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color pale = Color(0xFFB9D3FF);
  static const Color outline = Color(0xFF2C57D6);

  static const String font = 'BarlowCondensed';

  /// Skew applied to HUD text and buttons.
  static const double skew = -0.18;

  static const TextStyle label = TextStyle(
    fontFamily: font,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    fontSize: 14,
    letterSpacing: 1.4,
    color: sky,
  );

  static const TextStyle body = TextStyle(fontSize: 12.5, color: pale);

  static const TextStyle stat = TextStyle(
    fontFamily: font,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: white,
    height: 1,
  );

  static String kilometres(double meters) => (meters / 1000).toStringAsFixed(1);

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: navy,
    colorScheme: const ColorScheme.dark(
      primary: blue,
      secondary: gold,
      surface: navy,
      error: red,
    ),
    useMaterial3: true,
  );
}

/// White italic text with a navy outline and a hard blue drop, like a game
/// HUD counter.
class SonicHudText extends StatelessWidget {
  const SonicHudText(
    this.text, {
    required this.size,
    this.drop = SonicTheme.blue,
    this.skewed = true,
    super.key,
  });

  final String text;
  final double size;
  final Color drop;
  final bool skewed;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: SonicTheme.font,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      fontSize: size,
      height: 1,
      letterSpacing: -size * 0.02,
    );
    final offset = Offset(size * 0.06, size * 0.06);
    final child = Stack(
      children: [
        Transform.translate(
          offset: offset,
          child: Text(text, style: base.copyWith(color: drop)),
        ),
        Transform.translate(
          offset: offset,
          child: Text(
            text,
            style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = size * 0.07
                ..strokeJoin = StrokeJoin.round
                ..color = drop,
            ),
          ),
        ),
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.07
              ..strokeJoin = StrokeJoin.round
              ..color = SonicTheme.navy,
          ),
        ),
        Text(text, style: base.copyWith(color: SonicTheme.white)),
      ],
    );
    return skewed
        ? Transform(
            transform: Matrix4.skewX(SonicTheme.skew * 0.5),
            child: child,
          )
        : child;
  }
}

/// Chevron-shaped action: skewed box with a hard shadow and a glossy top.
class SonicButton extends StatelessWidget {
  const SonicButton({
    required this.label,
    required this.onTap,
    this.caption,
    this.color = SonicTheme.blue,
    this.shadow = SonicTheme.blueDeep,
    this.height = 52,
    this.fontSize = 17,
    this.semanticsLabel,
    super.key,
  });

  final String label;
  final String? caption;
  final VoidCallback onTap;
  final Color color;
  final Color shadow;
  final double height;
  final double fontSize;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticsLabel ?? label,
    child: ExcludeSemantics(
      child: Transform(
        transform: Matrix4.skewX(SonicTheme.skew),
        alignment: Alignment.center,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: shadow, offset: const Offset(0, 5)),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5],
                ),
              ),
              child: Transform(
                transform: Matrix4.skewX(-SonicTheme.skew),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontFamily: SonicTheme.font,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          fontSize: fontSize,
                          letterSpacing: 0.8,
                          color: SonicTheme.white,
                          height: 1,
                        ),
                      ),
                      if (caption != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          caption!,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.4,
                            height: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Navy HUD panel with diagonal speed stripes and a slanted blue top edge.
class SonicPanel extends StatelessWidget {
  const SonicPanel({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 18),
    this.slantedTop = true,
    this.fill = false,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool slantedTop;

  /// Take all the height the parent offers (needed when [child] scrolls or
  /// uses `Expanded`); otherwise the panel hugs its content.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final body = DecoratedBox(
      decoration: const BoxDecoration(color: SonicTheme.navy),
      child: CustomPaint(
        painter: const _StripesPainter(),
        child: Padding(padding: padding, child: child),
      ),
    );
    return Column(
      mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (slantedTop)
          const SizedBox(
            height: 18,
            child: CustomPaint(painter: _SlantPainter()),
          ),
        if (fill) Expanded(child: body) else body,
      ],
    );
  }
}

class _SlantPainter extends CustomPainter {
  const _SlantPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final white = Path()
      ..moveTo(0, size.height * 0.55 - 4)
      ..lineTo(size.width, -4)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height * 0.55)
      ..close();
    canvas
      ..drawPath(white, Paint()..color = SonicTheme.white)
      ..drawPath(blue, Paint()..color = SonicTheme.blue)
      ..drawRect(
        Rect.fromLTWH(0, size.height - 1, size.width, 1),
        Paint()..color = SonicTheme.navy,
      );
  }

  @override
  bool shouldRepaint(_SlantPainter oldDelegate) => false;
}

class _StripesPainter extends CustomPainter {
  const _StripesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.045);
    const step = 28.0;
    const width = 10.0;
    final slope = math.tan(math.pi / 3);
    for (var x = -size.height / slope; x < size.width + step; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height / slope, 0)
        ..lineTo(x + size.height / slope + width, 0)
        ..lineTo(x + width, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => false;
}

/// Gold rank badge (S, A, B, C), tilted like a stamp.
class SonicRank extends StatelessWidget {
  const SonicRank(this.rank, {this.size = 54, super.key});

  final String rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (top, bottom, shadow) = switch (rank) {
      'S' || 'A' => (
        const Color(0xFFFFE37A),
        const Color(0xFFF0A800),
        SonicTheme.goldDeep,
      ),
      'B' => (
        const Color(0xFFD9E6FF),
        const Color(0xFF9FB8F0),
        const Color(0xFF4661A0),
      ),
      _ => (
        const Color(0xFFFFB493),
        const Color(0xFFE2733F),
        const Color(0xFF8B3A14),
      ),
    };
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.26),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: Text(
          rank,
          style: TextStyle(
            fontFamily: SonicTheme.font,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontSize: size * 0.66,
            color: SonicTheme.navy,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// HUD chip: gold outline on navy, for counters and the back action.
class SonicHudChip extends StatelessWidget {
  const SonicHudChip({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: SonicTheme.navy,
    shape: const StadiumBorder(
      side: BorderSide(color: SonicTheme.gold, width: 2),
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: SonicTheme.font,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: SonicTheme.gold,
            height: 1,
          ),
          child: child,
        ),
      ),
    ),
  );
}

class SonicSpotIcon extends StatelessWidget {
  const SonicSpotIcon({this.size = 14, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: SonicTheme.gold, width: size * 0.22),
    ),
  );
}

/// Small white slanted chip, used for zone names on the map.
class SonicChip extends StatelessWidget {
  const SonicChip(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Transform(
    transform: Matrix4.skewX(SonicTheme.skew),
    alignment: Alignment.center,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SonicTheme.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(color: SonicTheme.navy, offset: Offset(0, 3)),
        ],
      ),
      child: Transform(
        transform: Matrix4.skewX(-SonicTheme.skew),
        alignment: Alignment.center,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontFamily: SonicTheme.font,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 1,
            color: SonicTheme.navy,
            height: 1,
          ),
        ),
      ),
    ),
  );
}

/// Stat tile on the HUD panel: big condensed value with a small sky label.
class SonicStat extends StatelessWidget {
  const SonicStat({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
    decoration: BoxDecoration(
      color: SonicTheme.navyDeep,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1F3FA0), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: SonicTheme.stat),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            color: SonicTheme.sky,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

/// Key/value row with a gold edge, for result screens.
class SonicRow extends StatelessWidget {
  const SonicRow({
    required this.label,
    required this.value,
    this.gold = false,
    super.key,
  });

  final String label;
  final String value;
  final bool gold;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: const BoxDecoration(
      color: SonicTheme.navyDeep,
      borderRadius: BorderRadius.all(Radius.circular(6)),
      border: Border(left: BorderSide(color: SonicTheme.gold, width: 4)),
    ),
    child: Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: SonicTheme.sky,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: SonicTheme.font,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: gold ? SonicTheme.gold : SonicTheme.white,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

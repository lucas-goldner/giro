import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/map_settings_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/demo/tokyo_demo_data.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/map_settings.dart';
import 'package:giro/design/sonic/sonic_actions.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Options: how thick the trails are drawn and how far they lift the fog.
class SonicOptionsPage extends StatelessWidget {
  const SonicOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<MapSettingsCubit>().state;
    final cubit = context.read<MapSettingsCubit>();
    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: SonicPanel(
        slantedTop: false,
        fill: true,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Row(
                children: [
                  SonicHudChip(
                    onTap: context.navigator.pop,
                    child: const Text('◀  BACK'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'SETTINGS',
                        style: SonicTheme.label.copyWith(
                          color: SonicTheme.gold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SonicHudText('OPTIONS', size: 34),
              const SizedBox(height: 6),
              const Text(
                'Tune how your walks show on the map. Changes apply '
                'everywhere right away.',
                style: SonicTheme.body,
              ),
              const SizedBox(height: 22),
              _OptionSlider(
                title: 'TRAIL WIDTH',
                caption: 'How thick each walk is drawn.',
                value: settings.trailWidth,
                min: MapSettings.minTrailWidth,
                max: MapSettings.maxTrailWidth,
                format: (v) => '${v.round()} px',
                semanticsLabel: 'Trail width',
                onChanged: cubit.setTrailWidth,
                preview: _TrailPreview(width: settings.trailWidth),
              ),
              const SizedBox(height: 18),
              _OptionSlider(
                title: 'REVEAL RADIUS',
                caption:
                    'How far around a walk the fog of war is lifted. '
                    'Bigger means the city fills in faster.',
                value: settings.revealRadiusMeters,
                min: MapSettings.minRevealRadius,
                max: MapSettings.maxRevealRadius,
                format: (v) => '${v.round()} m',
                semanticsLabel: 'Reveal radius',
                onChanged: cubit.setRevealRadius,
                preview: _RevealPreview(radius: settings.revealRadiusMeters),
              ),
              const SizedBox(height: 22),
              SonicButton(
                label: 'Reset to defaults',
                caption:
                    '${MapSettings.defaultTrailWidth.round()} px · '
                    '${MapSettings.defaultRevealRadius.round()} m',
                onTap: () => cubit.update(
                  settings.copyWith(
                    trailWidth: MapSettings.defaultTrailWidth,
                    revealRadiusMeters: MapSettings.defaultRevealRadius,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text('MAP DATA', style: SonicTheme.label),
              const SizedBox(height: 6),
              const Text(
                'Download your city once so the map is instant and works '
                'without a connection.',
                style: SonicTheme.body,
              ),
              const SizedBox(height: 12),
              SonicButton(
                label: 'Download map area',
                caption: 'Offline tiles',
                color: SonicTheme.gold,
                shadow: SonicTheme.goldDeep,
                onTap: () => SonicActions.mapDownload(context),
              ),
              const SizedBox(height: 26),
              const _DemoDataSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionSlider extends StatelessWidget {
  const _OptionSlider({
    required this.title,
    required this.caption,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.semanticsLabel,
    required this.onChanged,
    required this.preview,
  });

  final String title;
  final String caption;
  final double value;
  final double min;
  final double max;
  final String Function(double) format;
  final String semanticsLabel;
  final ValueChanged<double> onChanged;
  final Widget preview;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
    decoration: BoxDecoration(
      color: SonicTheme.navyDeep,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1F3FA0), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: SonicTheme.label)),
            Text(format(value), style: SonicTheme.stat),
          ],
        ),
        const SizedBox(height: 4),
        Text(caption, style: SonicTheme.body),
        const SizedBox(height: 10),
        SizedBox(height: 44, child: preview),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: SonicTheme.gold,
            inactiveTrackColor: SonicTheme.outline.withValues(alpha: 0.5),
            thumbColor: SonicTheme.white,
            overlayColor: SonicTheme.gold.withValues(alpha: 0.2),
            trackHeight: 6,
          ),
          child: Semantics(
            label: semanticsLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A sample walk line at the chosen width.
class _TrailPreview extends StatelessWidget {
  const _TrailPreview({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _TrailPainter(width),
    child: const SizedBox.expand(),
  );
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.width);

  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(8, size.height * 0.7)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.9,
        size.width * 0.5,
        0,
        size.width - 8,
        size.height * 0.4,
      );
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = SonicTheme.sky.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * 2.6,
      )
      ..drawPath(
        path,
        Paint()
          ..color = SonicTheme.blue
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width,
      );
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) => oldDelegate.width != width;
}

/// The fog lifted around a sample walk, to scale with the radius.
class _RevealPreview extends StatelessWidget {
  const _RevealPreview({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: CustomPaint(
      painter: _RevealPainter(radius),
      child: const SizedBox.expand(),
    ),
  );
}

class _RevealPainter extends CustomPainter {
  _RevealPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    // 1 px = 10 m, so the whole preview is about half a kilometre across.
    final px = radius / 10;
    final rect = Offset.zero & size;
    canvas
      ..drawRect(rect, Paint()..color = SonicTheme.pale)
      ..saveLayer(rect, Paint())
      ..drawRect(
        rect,
        Paint()..color = SonicTheme.white.withValues(alpha: 0.97),
      )
      ..drawLine(
        Offset(10, size.height / 2),
        Offset(size.width - 10, size.height / 2),
        Paint()
          ..color = Colors.black
          ..blendMode = BlendMode.dstOut
          ..strokeCap = StrokeCap.round
          ..strokeWidth = px * 2
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (px * 0.3).clamp(1, 12),
          ),
      )
      ..restore()
      ..drawLine(
        Offset(10, size.height / 2),
        Offset(size.width - 10, size.height / 2),
        Paint()
          ..color = SonicTheme.blue
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4,
      );
  }

  @override
  bool shouldRepaint(_RevealPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Fills the app with generated walks across all 23 wards, to preview the
/// look of a mostly explored Tokyo. Generated from a fixed seed, so the
/// same walks can be removed again without touching real data.
class _DemoDataSection extends StatelessWidget {
  const _DemoDataSection();

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<WalkRoutesCubit>().state.routes;
    final demoIds = {for (final route in TokyoDemoData.walks()) route.id};
    final loaded = routes.where((route) => demoIds.contains(route.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DEMO DATA', style: SonicTheme.label),
        const SizedBox(height: 6),
        Text(
          loaded == 0
              ? 'Preview a Tokyo that is almost fully explored: '
                    '${demoIds.length} generated walks across all 23 wards '
                    'and ${TokyoDemoData.spots().length} famous spots. '
                    'Real walks stay untouched.'
              : '$loaded demo walks loaded. Remove them to get back to '
                    'your own stages.',
          style: SonicTheme.body,
        ),
        const SizedBox(height: 12),
        if (loaded == 0)
          SonicButton(
            label: 'Fill Tokyo',
            caption: 'Generated walks and spots',
            semanticsLabel: 'Fill Tokyo',
            color: SonicTheme.red,
            shadow: SonicTheme.redDeep,
            onTap: () {
              context.read<WalkRoutesCubit>().addRoutes(TokyoDemoData.walks());
              context.read<PoiCubit>().addPOIs(TokyoDemoData.spots());
            },
          )
        else
          SonicButton(
            label: 'Remove demo data',
            caption: 'Keeps your real walks',
            semanticsLabel: 'Remove demo data',
            onTap: () {
              context.read<WalkRoutesCubit>().removeRoutesByIds(demoIds);
              context.read<PoiCubit>().removePOIsByIds({
                for (final poi in TokyoDemoData.spots()) poi.id,
              });
            },
          ),
      ],
    );
  }
}

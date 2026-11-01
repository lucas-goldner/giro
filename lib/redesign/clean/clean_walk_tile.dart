import 'package:flutter/material.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/redesign/clean/clean_theme.dart';
import 'package:giro/redesign/route_preview.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';

/// komoot-style activity row: square route sketch, bold date, a stat line
/// with icons, and a chevron. Used on the home sheet and the walks list.
class CleanWalkTile extends StatelessWidget {
  const CleanWalkTile({required this.route, super.key});

  final WalkRoute route;

  @override
  Widget build(BuildContext context) {
    final palette = CleanTheme.palette;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: () => context.navigator.pushNamed(
        RouteDetailPage.routeName,
        arguments: route,
      ),
      leading: SizedBox(
        width: 60,
        height: 60,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: RoutePreview(
            points: route.coordinates,
            color: palette.primary,
            background: CleanTheme.fill,
            strokeWidth: 2.5,
          ),
        ),
      ),
      title: Text(
        CleanTheme.shortDate(route.startDate),
        style: CleanTheme.headline.copyWith(color: palette.ink),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            _Stat(icon: Icons.straighten_rounded, text: route.distanceLabel),
            const SizedBox(width: 12),
            _Stat(icon: Icons.schedule_rounded, text: route.durationLabel),
          ],
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: palette.muted),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: CleanTheme.palette.muted),
      const SizedBox(width: 4),
      Text(
        text,
        style: CleanTheme.footnote.copyWith(color: CleanTheme.palette.muted),
      ),
    ],
  );
}

/// Hairline divider aligned with the text column of [CleanWalkTile].
class CleanDivider extends StatelessWidget {
  const CleanDivider({this.indent = 96, super.key});

  final double indent;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: indent,
    endIndent: 0,
    color: CleanTheme.hairline,
  );
}

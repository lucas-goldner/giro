import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/redesign/design_variant.dart';
import 'package:giro/redesign/route_preview.dart';
import 'package:giro/redesign/walk_stats.dart';
import 'package:giro/route_detail/screen/route_detail.dart';

/// The walks list, restyled with the palette of the active [DesignVariant].
/// Replaces the "Routes Management" screen: route sketches instead of bare
/// text rows, distance and duration up front, swipe-free delete via menu.
class RedesignRoutesPage extends StatelessWidget {
  const RedesignRoutesPage({required this.variant, super.key});

  final DesignVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = variant.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final heavy = variant == DesignVariant.blocks;
    final rows = palette.listStyle == RedesignListStyle.rows;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Text(
          'Walks',
          style: TextStyle(
            color: palette.ink,
            fontWeight: heavy ? FontWeight.w900 : FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(
            '${routes.length} walks · '
            '${formatDistance(routes.totalDistanceMeters)} · '
            '${formatDuration(routes.totalDuration)}',
            style: TextStyle(color: palette.muted, fontSize: 14),
          ),
          const SizedBox(height: 14),
          for (final (index, route) in routes.indexed) ...[
            if (rows && index > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: palette.muted.withValues(alpha: 0.25),
              ),
            _RouteTile(palette: palette, route: route, heavy: heavy),
            if (!rows) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({
    required this.palette,
    required this.route,
    required this.heavy,
  });

  final RedesignPalette palette;
  final WalkRoute route;
  final bool heavy;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.listStyle == RedesignListStyle.rows
        ? Colors.transparent
        : palette.surface,
    borderRadius: BorderRadius.circular(palette.radius),
    child: InkWell(
      borderRadius: BorderRadius.circular(palette.radius),
      onTap: () => context.navigator.pushNamed(
        RouteDetailPage.routeName,
        arguments: route,
      ),
      child: Container(
        padding: palette.listStyle == RedesignListStyle.rows
            ? const EdgeInsets.symmetric(vertical: 14)
            : const EdgeInsets.all(12),
        decoration: heavy
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(palette.radius),
                border: Border.all(color: palette.ink, width: 2.5),
              )
            : null,
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RoutePreview(
                  points: route.coordinates,
                  color: palette.isDark ? palette.accent : palette.primary,
                  background: palette.isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : palette.background,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.startDate.toLocalizedString(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.ink,
                      fontWeight: heavy ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Stat(
                        palette: palette,
                        icon: Icons.straighten_rounded,
                        text: route.distanceLabel,
                      ),
                      const SizedBox(width: 12),
                      _Stat(
                        palette: palette,
                        icon: Icons.schedule_rounded,
                        text: route.durationLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: palette.muted),
              onSelected: (_) =>
                  context.read<WalkRoutesCubit>().removeRoute(route),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete walk')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.palette, required this.icon, required this.text});

  final RedesignPalette palette;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 15, color: palette.muted),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          color: palette.muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/redesign/clean/clean_theme.dart';
import 'package:giro/redesign/clean/clean_walk_tile.dart';
import 'package:giro/redesign/walk_stats.dart';

/// All walks, grouped by month, with iOS swipe-to-delete.
class CleanWalksPage extends StatelessWidget {
  const CleanWalksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = CleanTheme.palette;
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final groups = <String, List<WalkRoute>>{};
    for (final route in routes) {
      groups
          .putIfAbsent(CleanTheme.monthYear(route.startDate), () => [])
          .add(route);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walks',
                  style: CleanTheme.largeTitle.copyWith(color: palette.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  '${routes.length} walks · '
                  '${formatDistance(routes.totalDistanceMeters)} · '
                  '${formatDuration(routes.totalDuration)}',
                  style: CleanTheme.body.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                entry.key.toUpperCase(),
                style: CleanTheme.micro.copyWith(color: palette.muted),
              ),
            ),
            for (final (index, route) in entry.value.indexed) ...[
              if (index > 0) const CleanDivider(),
              Dismissible(
                key: ValueKey(route.id),
                direction: DismissDirection.endToStart,
                background: const ColoredBox(
                  color: CleanTheme.destructive,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 24),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onDismissed: (_) =>
                    context.read<WalkRoutesCubit>().removeRoute(route),
                child: CleanWalkTile(route: route),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

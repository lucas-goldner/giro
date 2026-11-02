import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/walk_route.dart';
import 'package:giro/core/router.dart';
import 'package:giro/design/shared/route_preview.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_actions.dart';
import 'package:giro/design/sonic/sonic_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Stage select: every walk is a card with its rank, route sketch and the
/// rings collected on it.
class SonicWalksPage extends StatelessWidget {
  const SonicWalksPage({super.key});

  static const _ringRadiusMeters = 400.0;

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<WalkRoutesCubit>().state.sortedRoutes;
    final pois = context.watch<PoiCubit>().state.pois;
    final km = SonicTheme.kilometres(routes.totalDistanceMeters);

    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: SonicPanel(
        fill: true,
        slantedTop: false,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SonicRingChip(
                          onTap: context.navigator.pop,
                          child: const Text('◀  BACK'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'STAGE SELECT',
                              style: SonicTheme.label.copyWith(
                                color: SonicTheme.gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SonicHudText('TOKYO · ${routes.length} STAGES', size: 34),
                    const SizedBox(height: 6),
                    Text(
                      '$km km · '
                      '${formatDuration(routes.totalDuration)} · '
                      '${pois.length} rings',
                      style: SonicTheme.body,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 90),
                  itemCount: routes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    final share = SonicStats.newGroundShare(
                      route,
                      SonicStats.earlierThan(route, routes),
                    );
                    final rings = pois
                        .where(
                          (poi) =>
                              route.distanceTo(poi.coordinates) <=
                              _ringRadiusMeters,
                        )
                        .length;
                    return _StageCard(
                      route: route,
                      rank: SonicStats.rankFor(share),
                      rings: rings,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 130,
        child: SonicButton(
          label: 'GO!',
          caption: 'Record a walk',
          semanticsLabel: 'Record',
          color: SonicTheme.red,
          shadow: SonicTheme.redDeep,
          fontSize: 26,
          height: 56,
          onTap: () => SonicActions.record(context),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.route,
    required this.rank,
    required this.rings,
  });

  final WalkRoute route;
  final String rank;
  final int rings;

  @override
  Widget build(BuildContext context) {
    final date = route.startDate.toLocalizedString(context);
    final meta =
        '$date · ${route.distanceLabel} · ${route.durationLabel} · '
        '$rings ring${rings == 1 ? '' : 's'}';
    return Semantics(
      button: true,
      label: 'Stage $date, ${route.distanceLabel}, rank $rank',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.navigator.pushNamed(
              AppRoutes.walkDetail,
              arguments: route,
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A3CAB), Color(0xFF0F2A84)],
                ),
                border: Border.all(color: SonicTheme.outline, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF061240), offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RoutePreview(
                        points: route.coordinates,
                        color: SonicTheme.sky,
                        background: SonicTheme.navyDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STAGE ${route.startDate.day}',
                          style: const TextStyle(
                            fontFamily: SonicTheme.font,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            fontSize: 19,
                            color: SonicTheme.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: SonicTheme.pale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SonicRank(rank, size: 44),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

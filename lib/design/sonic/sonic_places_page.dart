import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/design/shared/walk_stats.dart';
import 'package:giro/design/sonic/sonic_theme.dart';

/// Rings: every saved place, which walks collected it, open it in Maps,
/// swipe to drop it.
class SonicPlacesPage extends StatelessWidget {
  const SonicPlacesPage({super.key});

  static const _ringRadiusMeters = 400.0;

  @override
  Widget build(BuildContext context) {
    final pois = context.watch<PoiCubit>().state.pois;
    final routes = context.watch<WalkRoutesCubit>().state.routes;

    return Scaffold(
      backgroundColor: SonicTheme.navy,
      body: SonicPanel(
        slantedTop: false,
        fill: true,
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
                              'RING COLLECTION',
                              style: SonicTheme.label.copyWith(
                                color: SonicTheme.gold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SonicHudText('${pois.length} RINGS', size: 34),
                    const SizedBox(height: 6),
                    const Text(
                      'Press and hold the map to drop a ring. Swipe one away '
                      'to lose it.',
                      style: SonicTheme.body,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                  itemCount: pois.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final poi = pois[index];
                    final collectedBy = routes
                        .where(
                          (route) =>
                              route.distanceTo(poi.coordinates) <=
                              _ringRadiusMeters,
                        )
                        .length;
                    return Dismissible(
                      key: ValueKey(poi.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 22),
                        decoration: BoxDecoration(
                          color: SonicTheme.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) =>
                          context.read<PoiCubit>().removePOI(poi),
                      child: _RingCard(poi: poi, collectedBy: collectedBy),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingCard extends StatelessWidget {
  const _RingCard({required this.poi, required this.collectedBy});

  final POI poi;
  final int collectedBy;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Ring ${poi.name}',
    child: ExcludeSemantics(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.read<LaunchableMapsCubit>().launchMapAtPOI(poi),
          child: Container(
            padding: const EdgeInsets.all(12),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: SonicTheme.navyDeep,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const SonicRingIcon(size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: SonicTheme.font,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          color: SonicTheme.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dropped ${poi.createdAt.toLocalizedString(context)} · '
                        'collected by $collectedBy '
                        'walk${collectedBy == 1 ? '' : 's'}',
                        style: SonicTheme.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new_rounded, color: SonicTheme.sky),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/widgets/adaptive_scaffold.dart';
import 'package:giro/poi_management/widgets/poi_card.dart';

class POIManagementPage extends StatelessWidget {
  const POIManagementPage({super.key});
  static const String routeName = '/pois_management';

  @override
  Widget build(BuildContext context) => const POIManagement();
}

class POIManagement extends StatefulWidget {
  const POIManagement({super.key});

  @override
  State<POIManagement> createState() => _POIManagementState();
}

class _POIManagementState extends State<POIManagement> {
  @override
  Widget build(BuildContext context) {
    final pois = context.watch<PoiCubit>().state.pois;

    return AdaptiveScaffold(
      title: const Text('POI Management'),
      child: SafeArea(
        child: Column(
          children: [
            if (kDebugMode)
              CupertinoButton.filled(
                onPressed: context.read<PoiCubit>().clearAll,
                child: const Text('Clear all'),
              ),
            Flexible(
              child: ListView.builder(
                itemCount: pois.length,
                itemBuilder: (context, index) => PoiCard(
                  pois[index],
                  onSelected: (poi) {
                    print('LAUNCHING POI DETAIL');
                  },
                  onDelete: (poi) => context.read<PoiCubit>().removePOI(poi),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

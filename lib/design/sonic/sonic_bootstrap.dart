import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';

/// Loads walks, places and launchable map apps once, before the home
/// screen shows.
class SonicBootstrap extends StatefulWidget {
  const SonicBootstrap({required this.child, super.key});

  final Widget child;

  @override
  State<SonicBootstrap> createState() => _SonicBootstrapState();
}

class _SonicBootstrapState extends State<SonicBootstrap> {
  @override
  void initState() {
    super.initState();
    context.read<WalkRoutesCubit>().fetchRoutes();
    context.read<PoiCubit>().fetchPOIs();
    unawaited(context.read<LaunchableMapsCubit>().fetchAvailableMaps());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';

/// Loads walks, places and launchable map apps once, like the current home
/// screen does, before showing a redesign home.
class RedesignBootstrap extends StatefulWidget {
  const RedesignBootstrap({required this.child, super.key});

  final Widget child;

  @override
  State<RedesignBootstrap> createState() => _RedesignBootstrapState();
}

class _RedesignBootstrapState extends State<RedesignBootstrap> {
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

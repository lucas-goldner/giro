import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/routes_management/widgets/route_card.dart';

class RouteManagementPage extends StatelessWidget {
  const RouteManagementPage({super.key});
  static const String routeName = '/routes_management';

  MaterialPageRoute<void> get route => MaterialPageRoute(
        builder: (_) => this,
      );

  @override
  Widget build(BuildContext context) => const RoutesManagement();
}

class RoutesManagement extends StatefulWidget {
  const RoutesManagement({super.key});

  @override
  State<RoutesManagement> createState() => _RoutesManagementState();
}

class _RoutesManagementState extends State<RoutesManagement> {
  @override
  Widget build(BuildContext context) {
    final routes = context.watch<WalkRoutesCubit>().state.routes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes Management'),
      ),
      body: Column(
        children: [
          if (kDebugMode)
            CupertinoButton.filled(
              onPressed: context.read<WalkRoutesCubit>().clearAll,
              child: const Text('Clear all'),
            ),
          Flexible(
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) => RouteCard(
                routes[index],
                onSelected: (route) => context.navigator.pushNamed(
                  RouteManagementPage.routeName,
                  arguments: route,
                ),
                onDelete: (route) =>
                    context.read<WalkRoutesCubit>().removeRoute(route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

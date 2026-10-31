import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/model/app_init_deps.dart';
import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:giro/core/repository/poi_repo.dart';
import 'package:giro/core/repository/walk_routes_repo.dart';
import 'package:giro/core/widgets/adaptive_app.dart';
import 'package:giro/map/repository/healthkit_repo.dart';
import 'package:intl/date_symbol_data_local.dart';

class GiroApp extends StatefulWidget {
  const GiroApp({required this.loadDeps, super.key});

  /// Builds the platform-specific repositories (see `loadNativeDeps` and
  /// `loadWebMockDeps`).
  final AppDepsLoader loadDeps;

  @override
  State<GiroApp> createState() => _GiroAppState();
}

class _GiroAppState extends State<GiroApp> {
  Future<AppInitDeps>? _appLoader;

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLoader ??= widget.loadDeps();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppInitDeps>(
        future: _appLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!WidgetsBinding.instance.firstFrameRasterized) {
              WidgetsBinding.instance.allowFirstFrame();
            }

            final deps = snapshot.requireData;

            return MultiRepositoryProvider(
              providers: [
                RepositoryProvider<WalkRoutesRepo>.value(
                  value: deps.walkRoutesRepo,
                ),
                RepositoryProvider<PoiRepo>.value(value: deps.poiRepo),
                RepositoryProvider<LaunchableMapsRepo>.value(
                  value: deps.launchableMapsRepo,
                ),
                RepositoryProvider<HealthkitRepo>.value(
                  value: deps.healthkitRepo,
                ),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<WalkRoutesCubit>(
                    create: (context) => WalkRoutesCubit(deps.walkRoutesRepo),
                  ),
                  BlocProvider<PoiCubit>(
                    create: (context) => PoiCubit(deps.poiRepo),
                  ),
                  BlocProvider<LaunchableMapsCubit>(
                    create: (context) =>
                        LaunchableMapsCubit(deps.launchableMapsRepo),
                  ),
                ],
                child: const AdaptiveApp(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
}

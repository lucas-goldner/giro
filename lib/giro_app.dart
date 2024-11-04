import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/launchable_maps_cubit.dart';
import 'package:giro/core/cubit/poi_cubit.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/model/app_init_deps.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/repository/launchable_maps_repo_impl.dart';
import 'package:giro/core/repository/poi_repo_mmkv_impl.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/router.dart';
import 'package:intl/date_symbol_data_local.dart';

class GiroApp extends StatefulWidget {
  const GiroApp({super.key});

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
    _appLoader ??= _loadApp();
  }

  Future<AppInitDeps> _loadApp() async {
    final walkRoutesRepo = WalkRoutesRepoMmkvImpl();
    await walkRoutesRepo.init();
    final poiRepo = PoiRepoMmkvImpl();
    await poiRepo.init();
    final launchableMapsRepo = LaunchableMapsRepoImpl();

    return AppInitDeps(
      walkRoutesRepo: walkRoutesRepo,
      poiRepo: poiRepo,
      launchableMapsRepo: launchableMapsRepo,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppInitDeps>(
        future: _appLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!WidgetsBinding.instance.firstFrameRasterized) {
              WidgetsBinding.instance.allowFirstFrame();
            }

            return MultiBlocProvider(
              providers: [
                BlocProvider<WalkRoutesCubit>(
                  create: (context) => WalkRoutesCubit(
                    snapshot.requireData.walkRoutesRepo,
                  ),
                ),
                BlocProvider<PoiCubit>(
                  create: (context) => PoiCubit(
                    snapshot.requireData.poiRepo,
                  ),
                ),
                BlocProvider<LaunchableMapsCubit>(
                  create: (context) => LaunchableMapsCubit(
                    snapshot.requireData.launchableMapsRepo,
                  ),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: FlavorConfig.isDev(),
                onGenerateRoute: generateRoutes,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
}

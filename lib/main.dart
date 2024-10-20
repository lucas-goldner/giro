import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/cubit/walk_routes_cubit.dart';
import 'package:giro/core/repository/walk_routes_repo_mmkv_impl.dart';
import 'package:giro/router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const GiroApp());
}

class GiroApp extends StatefulWidget {
  const GiroApp({super.key});

  @override
  State<GiroApp> createState() => _GiroAppState();
}

class _GiroAppState extends State<GiroApp> {
  Future<WalkRoutesRepoMmkvImpl>? _appLoader;

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

  Future<WalkRoutesRepoMmkvImpl> _loadApp() async {
    final walkRoutesRepo = WalkRoutesRepoMmkvImpl();
    await walkRoutesRepo.init();

    return walkRoutesRepo;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<WalkRoutesRepoMmkvImpl>(
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
                    snapshot.requireData,
                  ),
                ),
              ],
              child: const MaterialApp(
                onGenerateRoute: generateRoutes,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
}

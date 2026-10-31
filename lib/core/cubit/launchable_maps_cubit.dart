import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giro/core/extensions.dart';
import 'package:giro/core/model/poi.dart';
import 'package:giro/core/repository/launchable_maps_repo.dart';
import 'package:map_launcher/map_launcher.dart';

part 'launchable_maps_state.dart';

class LaunchableMapsCubit extends Cubit<LaunchableMapsState> {
  LaunchableMapsCubit(this._launchableMapsRepo)
      : super(const LaunchableMapsInitial());

  final LaunchableMapsRepo _launchableMapsRepo;

  Future<void> fetchAvailableMaps() async {
    emit(LaunchableMapsLoading(state.launchableMaps));
    final launchableMaps = await _launchableMapsRepo.fetchAvailableMaps();
    emit(LaunchableMapsLoaded([...launchableMaps]));
  }

  Future<void> launchMapAtPOI(POI poi) async {
    final currentState = state;

    if (currentState is! LaunchableMapsLoaded ||
        currentState.launchableMaps.isEmpty) {
      return;
    }

    final hasAppleMaps = currentState.hasMapApp(MapApp.apple);
    final hasGoogleMaps = currentState.hasMapApp(MapApp.google);

    if (Platform.isIOS) {
      if (hasAppleMaps) {
        await _launchMapAtPOI(MapApp.apple, poi);
        return;
      }

      if (hasGoogleMaps) {
        await _launchMapAtPOI(MapApp.google, poi);
        return;
      }
    }

    if (Platform.isAndroid && hasGoogleMaps) {
      await _launchMapAtPOI(MapApp.google, poi);
      return;
    }

    await _launchMapAtPOI(currentState.launchableMaps.first.map, poi);
  }

  Future<void> _launchMapAtPOI(MapApp map, POI poi) async {
    try {
      await MapLauncher.marker(
        poi.coordinates.toLocation(title: poi.name),
      ).show(map: map);
    } on MapLaunchException catch (_) {
      // The selected map app could not open the marker; nothing to recover.
    }
  }
}

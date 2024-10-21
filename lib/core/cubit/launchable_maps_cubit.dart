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

  void launchMapAtPOI(POI poi) {
    final currentState = state;

    if (currentState is! LaunchableMapsLoaded) {
      return;
    }

    final hasAppleMaps = currentState.mapTypes.contains(MapType.apple);
    final hasGoogleMaps = currentState.mapTypes.contains(MapType.apple);

    if (Platform.isIOS) {
      if (hasAppleMaps) {
        _launchPOIWithAppleMaps(poi);
        return;
      }

      if (hasGoogleMaps) {
        _launchPOIWithGoogleMaps(poi);
        return;
      }
    }

    if (Platform.isAndroid) {
      if (hasGoogleMaps) {
        _launchPOIWithGoogleMaps(poi);
        return;
      }
    }

    _launchMapAtPOI(currentState.launchableMaps.first, poi);
  }

  void _launchPOIWithAppleMaps(POI poi) {
    final appleMap =
        state.launchableMaps.firstWhere((map) => map.mapType == MapType.apple);
    _launchMapAtPOI(appleMap, poi);
  }

  void _launchPOIWithGoogleMaps(POI poi) {
    final googleMap =
        state.launchableMaps.firstWhere((map) => map.mapType == MapType.google);
    _launchMapAtPOI(googleMap, poi);
  }

  void _launchMapAtPOI(AvailableMap map, POI poi) {
    map.showMarker(
      title: poi.name,
      coords: poi.coordinates.toCoords(),
    );
  }
}

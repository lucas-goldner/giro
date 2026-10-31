import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

/// The real Google Maps JavaScript map for the web build.
///
/// platform_maps_flutter only switches between Apple Maps and Google Maps on
/// iOS/Android, so on the web this hands the same camera, markers and
/// polylines to google_maps_flutter (whose web implementation embeds the Maps
/// JavaScript API loaded in `web/index.html`). Without an API key Google still
/// renders the map, just dimmed with a "for development purposes only"
/// watermark, which is enough for checking the UI.
class WebGoogleMap extends StatelessWidget {
  const WebGoogleMap({
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.compassEnabled = true,
    this.onLongPress,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final void Function(LatLng)? onLongPress;

  // platform_maps_flutter's own `googleMapsMarker` / `toGoogleMapsPolylines`
  // conversions touch `dart:io` Platform (for the marker icon), which throws
  // on the web, so the few fields the app uses are converted here instead.
  static google.Marker _toGoogleMarker(Marker marker) => google.Marker(
        markerId: google.MarkerId(marker.markerId.value),
        position: google.LatLng(
          marker.position.latitude,
          marker.position.longitude,
        ),
        alpha: marker.alpha,
        visible: marker.visible,
        infoWindow: google.InfoWindow(
          title: marker.infoWindow.title,
          snippet: marker.infoWindow.snippet,
        ),
        onTap: marker.onTap,
      );

  static google.Polyline _toGooglePolyline(Polyline polyline) =>
      google.Polyline(
        polylineId: google.PolylineId(polyline.polylineId.value),
        points: [
          for (final point in polyline.points)
            google.LatLng(point.latitude, point.longitude),
        ],
        color: polyline.color,
        width: polyline.width,
        visible: polyline.visible,
        onTap: polyline.onTap,
      );

  @override
  Widget build(BuildContext context) => google.GoogleMap(
        initialCameraPosition: google.CameraPosition(
          target: google.LatLng(
            initialCameraPosition.target.latitude,
            initialCameraPosition.target.longitude,
          ),
          zoom: initialCameraPosition.zoom,
          bearing: initialCameraPosition.bearing,
          tilt: initialCameraPosition.tilt,
        ),
        markers: markers.map(_toGoogleMarker).toSet(),
        polylines: polylines.map(_toGooglePolyline).toSet(),
        myLocationEnabled: myLocationEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        onLongPress: onLongPress == null
            ? null
            : (position) => onLongPress!(
                  LatLng(position.latitude, position.longitude),
                ),
      );
}

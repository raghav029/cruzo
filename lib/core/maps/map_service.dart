import 'package:flutter/widgets.dart';
import 'map_models.dart';

abstract class MapService {
  Widget buildMapWidget({
    required List<AppMarker> markers,
    List<AppPolyline> polylines = const [],
    AppLatLng? center,
    double zoom = 13.0,
    double height = 220.0,
  });

  Future<AppLatLng?> geocode(String address);

  /// Returns decoded route points between origin and destination.
  /// Returns null if route unavailable or API fails.
  Future<List<AppLatLng>?> getRoute(AppLatLng origin, AppLatLng destination);
}

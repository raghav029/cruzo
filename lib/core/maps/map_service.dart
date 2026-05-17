import 'package:flutter/widgets.dart';
import 'map_models.dart';

abstract class MapService {
  Widget buildMapWidget({
    required List<AppMarker> markers,
    AppLatLng? center,
    double zoom = 13.0,
    double height = 220.0,
  });

  Future<AppLatLng?> geocode(String address);
}

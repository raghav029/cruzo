import 'package:flutter/foundation.dart';

@immutable
class AppLatLng {
  final double lat;
  final double lng;

  const AppLatLng(this.lat, this.lng);
}

enum AppMarkerType { pickup, drop, driver }

@immutable
class AppMarker {
  final String id;
  final AppLatLng position;
  final AppMarkerType type;
  final String? label;

  const AppMarker({
    required this.id,
    required this.position,
    required this.type,
    this.label,
  });
}

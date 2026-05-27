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

@immutable
class AppPolyline {
  final String id;
  final List<AppLatLng> points;
  final int color;
  final double width;
  final bool dashed;

  const AppPolyline({
    required this.id,
    required this.points,
    this.color = 0xFF1E88E5,
    this.width = 5.0,
    this.dashed = false,
  });
}

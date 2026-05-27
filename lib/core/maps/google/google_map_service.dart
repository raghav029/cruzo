import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../map_models.dart';
import '../map_service.dart';

const _kMapsApiKey = 'AIzaSyC9sZwKWA7N2v2eoz2QmmPsMijytWD1nXo';

class GoogleMapService implements MapService {
  BitmapDescriptor? _carIconCache;
  final _dio = Dio();

  Future<BitmapDescriptor> _buildCarIcon() async {
    if (_carIconCache != null) return _carIconCache!;
    _carIconCache = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/fleet/car.png',
    );
    return _carIconCache!;
  }

  @override
  Widget buildMapWidget({
    required List<AppMarker> markers,
    List<AppPolyline> polylines = const [],
    AppLatLng? center,
    double zoom = 13.0,
    double height = 220.0,
  }) {
    return _MapWidget(
      markers: markers,
      polylines: polylines,
      center: center,
      zoom: zoom,
      height: height,
      service: this,
    );
  }

  @override
  Future<AppLatLng?> geocode(String address) async {
    try {
      final resp = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {'address': address, 'key': _kMapsApiKey},
      );
      final status = resp.data['status'];
      final results = resp.data['results'] as List?;
      debugPrint('[Maps] geocode "$address" → status=$status results=${results?.length}');
      if (results == null || results.isEmpty) return null;
      final loc = results[0]['geometry']['location'];
      return AppLatLng(loc['lat'] as double, loc['lng'] as double);
    } catch (e) {
      debugPrint('[Maps] geocode error: $e');
      return null;
    }
  }

  @override
  Future<List<AppLatLng>?> getRoute(AppLatLng origin, AppLatLng destination) async {
    try {
      final resp = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.lat},${origin.lng}',
          'destination': '${destination.lat},${destination.lng}',
          'key': _kMapsApiKey,
        },
      );
      final status = resp.data['status'];
      final routes = resp.data['routes'] as List?;
      debugPrint('[Maps] directions → status=$status routes=${routes?.length}');
      if (routes == null || routes.isEmpty) return null;
      final encoded = routes[0]['overview_polyline']['points'] as String;
      return _decodePolyline(encoded);
    } catch (e) {
      debugPrint('[Maps] directions error: $e');
      return null;
    }
  }

  List<AppLatLng> _decodePolyline(String encoded) {
    final result = <AppLatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result0 = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);

      shift = 0;
      result0 = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);

      result.add(AppLatLng(lat / 1e5, lng / 1e5));
    }
    return result;
  }

  Future<Set<Marker>> buildGmMarkers(List<AppMarker> markers) async {
    final result = <Marker>{};
    for (final m in markers) {
      BitmapDescriptor icon;
      if (m.type == AppMarkerType.driver) {
        icon = await _buildCarIcon();
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(
          m.type == AppMarkerType.pickup ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        );
      }
      result.add(Marker(
        markerId: MarkerId(m.id),
        position: LatLng(m.position.lat, m.position.lng),
        icon: icon,
        infoWindow: m.label != null ? InfoWindow(title: m.label) : InfoWindow.noText,
      ));
    }
    return result;
  }

  Set<Polyline> buildGmPolylines(List<AppPolyline> polylines) {
    return polylines.map((p) {
      return Polyline(
        polylineId: PolylineId(p.id),
        points: p.points.map((pt) => LatLng(pt.lat, pt.lng)).toList(),
        color: Color(p.color),
        width: p.width.toInt(),
        patterns: p.dashed
            ? [PatternItem.dash(20), PatternItem.gap(10)]
            : [],
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );
    }).toSet();
  }

  void fitBounds(GoogleMapController controller, List<AppMarker> markers, List<AppPolyline> polylines) {
    final allPoints = [
      ...markers.map((m) => m.position),
      ...polylines.expand((p) => p.points),
    ];
    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.lat;
    double maxLat = allPoints.first.lat;
    double minLng = allPoints.first.lng;
    double maxLng = allPoints.first.lng;
    for (final pt in allPoints) {
      if (pt.lat < minLat) minLat = pt.lat;
      if (pt.lat > maxLat) maxLat = pt.lat;
      if (pt.lng < minLng) minLng = pt.lng;
      if (pt.lng > maxLng) maxLng = pt.lng;
    }
    const pad = 0.005;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - pad, minLng - pad),
          northeast: LatLng(maxLat + pad, maxLng + pad),
        ),
        56,
      ),
    );
  }
}

class _MapWidget extends StatefulWidget {
  final List<AppMarker> markers;
  final List<AppPolyline> polylines;
  final AppLatLng? center;
  final double zoom;
  final double height;
  final GoogleMapService service;

  const _MapWidget({
    required this.markers,
    required this.polylines,
    this.center,
    required this.zoom,
    required this.height,
    required this.service,
  });

  @override
  State<_MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<_MapWidget> {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_MapWidget old) {
    super.didUpdateWidget(old);
    if (old.markers != widget.markers || old.polylines != widget.polylines) {
      _load();
    }
  }

  Future<void> _load() async {
    final m = await widget.service.buildGmMarkers(widget.markers);
    final p = widget.service.buildGmPolylines(widget.polylines);
    if (!mounted) return;
    setState(() {
      _markers = m;
      _polylines = p;
    });
    if (_controller != null) {
      widget.service.fitBounds(_controller!, widget.markers, widget.polylines);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = widget.center != null
        ? LatLng(widget.center!.lat, widget.center!.lng)
        : widget.markers.isNotEmpty
            ? LatLng(widget.markers.first.position.lat, widget.markers.first.position.lng)
            : const LatLng(20.5937, 78.9629);

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: initialTarget, zoom: widget.zoom),
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (c) {
            _controller = c;
            widget.service.fitBounds(c, widget.markers, widget.polylines);
          },
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../map_models.dart';
import '../map_service.dart';

class GoogleMapService implements MapService {
  BitmapDescriptor? _carIconCache;

  Future<BitmapDescriptor> _buildCarIcon() async {
    if (_carIconCache != null) return _carIconCache!;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 56.0;
    final bodyPaint = Paint()..color = const Color(0xFF1565C0);
    // car body
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8, 18, 40, 22), const Radius.circular(5)),
      bodyPaint,
    );
    // roof
    final roof = Path()
      ..moveTo(14, 18)
      ..lineTo(18, 8)
      ..lineTo(38, 8)
      ..lineTo(42, 18)
      ..close();
    canvas.drawPath(roof, bodyPaint);
    // windshield
    canvas.drawPath(
      Path()
        ..moveTo(17, 17)
        ..lineTo(20, 9)
        ..lineTo(36, 9)
        ..lineTo(39, 17)
        ..close(),
      Paint()..color = const Color(0xFFB3E5FC),
    );
    // wheels
    final wheelPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(const Offset(18, 40), 7, wheelPaint);
    canvas.drawCircle(const Offset(38, 40), 7, wheelPaint);
    final rimPaint = Paint()..color = const Color(0xFF9E9E9E);
    canvas.drawCircle(const Offset(18, 40), 3, rimPaint);
    canvas.drawCircle(const Offset(38, 40), 3, rimPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    _carIconCache = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    return _carIconCache!;
  }

  @override
  Widget buildMapWidget({
    required List<AppMarker> markers,
    AppLatLng? center,
    double zoom = 13.0,
    double height = 220.0,
  }) {
    return _MapWidget(
      markers: markers,
      center: center,
      zoom: zoom,
      height: height,
      service: this,
    );
  }

  @override
  Future<AppLatLng?> geocode(String address) async => null;

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

  void fitBounds(GoogleMapController controller, List<AppMarker> markers) {
    double minLat = markers.first.position.lat;
    double maxLat = markers.first.position.lat;
    double minLng = markers.first.position.lng;
    double maxLng = markers.first.position.lng;
    for (final m in markers) {
      if (m.position.lat < minLat) minLat = m.position.lat;
      if (m.position.lat > maxLat) maxLat = m.position.lat;
      if (m.position.lng < minLng) minLng = m.position.lng;
      if (m.position.lng > maxLng) maxLng = m.position.lng;
    }
    const pad = 0.005;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - pad, minLng - pad),
          northeast: LatLng(maxLat + pad, maxLng + pad),
        ),
        48,
      ),
    );
  }
}

class _MapWidget extends StatefulWidget {
  final List<AppMarker> markers;
  final AppLatLng? center;
  final double zoom;
  final double height;
  final GoogleMapService service;

  const _MapWidget({
    required this.markers,
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
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  @override
  void didUpdateWidget(_MapWidget old) {
    super.didUpdateWidget(old);
    if (old.markers != widget.markers) _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final m = await widget.service.buildGmMarkers(widget.markers);
    if (!mounted) return;
    setState(() => _markers = m);
    if (_controller != null && widget.markers.length > 1) {
      widget.service.fitBounds(_controller!, widget.markers);
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
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (c) {
            _controller = c;
            if (widget.markers.length > 1) {
              widget.service.fitBounds(c, widget.markers);
            }
          },
        ),
      ),
    );
  }
}

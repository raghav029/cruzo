import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  final Dio _dio;
  Timer? _timer;
  String? _activeBookingId;

  DriverLocationService(this._dio);

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  void start(String bookingId) {
    if (_activeBookingId == bookingId && _timer != null) return;
    stop();
    _activeBookingId = bookingId;
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _push());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _activeBookingId = null;
  }

  Future<void> _push() async {
    final id = _activeBookingId;
    if (id == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await _dio.patch(
        '/api/bookings/$id/location',
        data: {'lat': pos.latitude, 'lng': pos.longitude},
      );
    } catch (_) {
      // silent — location push is best-effort
    }
  }
}

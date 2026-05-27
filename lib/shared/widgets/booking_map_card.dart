import 'package:flutter/material.dart';
import 'package:cruzo/core/di/injection.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'package:cruzo/core/maps/map_models.dart';
import 'package:cruzo/core/maps/map_service.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking.dart';
import 'cruzo_card.dart';

class BookingMapCard extends StatefulWidget {
  final Booking booking;

  const BookingMapCard({super.key, required this.booking});

  @override
  State<BookingMapCard> createState() => _BookingMapCardState();
}

class _BookingMapCardState extends State<BookingMapCard> {
  final _mapSvc = getIt<MapService>();
  bool _geocoding = false;
  AppLatLng? _pickupCoord;
  AppLatLng? _dropCoord;
  List<AppLatLng>? _routePoints;

  @override
  void initState() {
    super.initState();
    _resolveCoords();
  }

  @override
  void didUpdateWidget(BookingMapCard old) {
    super.didUpdateWidget(old);
    if (old.booking.id != widget.booking.id) {
      _pickupCoord = null;
      _dropCoord = null;
      _routePoints = null;
      _resolveCoords();
    }
  }

  Future<void> _resolveCoords() async {
    final b = widget.booking;

    // Already have coords from booking fields — just fetch route
    if (b.hasCoords) {
      final route = await _mapSvc.getRoute(
        AppLatLng(b.pickupLat!, b.pickupLng!),
        AppLatLng(b.dropLat!, b.dropLng!),
      );
      if (mounted) setState(() => _routePoints = route);
      return;
    }

    // No addresses to geocode
    if (b.pickupAddress.isEmpty && b.dropAddress.isEmpty) return;

    setState(() => _geocoding = true);

    final results = await Future.wait([
      b.pickupAddress.isNotEmpty ? _mapSvc.geocode(b.pickupAddress) : Future.value(null),
      b.dropAddress.isNotEmpty ? _mapSvc.geocode(b.dropAddress) : Future.value(null),
    ]);

    if (!mounted) return;
    setState(() {
      _pickupCoord = results[0];
      _dropCoord = results[1];
      _geocoding = false;
    });

    // Fetch route between pickup and drop
    final pickup = b.pickupLat != null
        ? AppLatLng(b.pickupLat!, b.pickupLng!)
        : results[0];
    final drop = b.dropLat != null
        ? AppLatLng(b.dropLat!, b.dropLng!)
        : results[1];
    if (pickup != null && drop != null) {
      final route = await _mapSvc.getRoute(pickup, drop);
      if (mounted) setState(() => _routePoints = route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    final pickupLat = b.pickupLat ?? _pickupCoord?.lat;
    final pickupLng = b.pickupLng ?? _pickupCoord?.lng;
    final dropLat = b.dropLat ?? _dropCoord?.lat;
    final dropLng = b.dropLng ?? _dropCoord?.lng;

    final hasPickup = pickupLat != null && pickupLng != null;
    final hasDrop = dropLat != null && dropLng != null;
    final hasDriver = b.hasDriverLocation;

    if (!hasPickup && !hasDrop && !hasDriver) {
      return CruzoCard(
        title: 'Trip Route',
        child: _geocoding
            ? const Center(child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)))
            : Row(
                children: [
                  const Icon(Icons.location_off_outlined, color: AppColors.darkFg3, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Location unavailable', style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3)),
                ],
              ),
      );
    }

    if (_geocoding && !hasDriver) {
      return CruzoCard(
        title: 'Trip Route',
        child: const Center(child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    final markers = <AppMarker>[
      if (hasPickup)
        AppMarker(
          id: 'pickup',
          position: AppLatLng(pickupLat!, pickupLng!),
          type: AppMarkerType.pickup,
          label: b.pickupAddress.isNotEmpty ? b.pickupAddress : 'Pickup',
        ),
      if (hasDrop)
        AppMarker(
          id: 'drop',
          position: AppLatLng(dropLat!, dropLng!),
          type: AppMarkerType.drop,
          label: b.dropAddress.isNotEmpty ? b.dropAddress : 'Drop',
        ),
      if (hasDriver)
        AppMarker(
          id: 'driver',
          position: AppLatLng(b.driverCurrentLat!, b.driverCurrentLng!),
          type: AppMarkerType.driver,
          label: b.driverName ?? 'Driver',
        ),
    ];

    final polylines = <AppPolyline>[
      if (_routePoints != null && _routePoints!.length > 1)
        AppPolyline(id: 'route', points: _routePoints!, color: 0xFF1E88E5, width: 5),
    ];

    return CruzoCard(
      title: 'Trip Route',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mapSvc.buildMapWidget(markers: markers, polylines: polylines, height: 220),
          const SizedBox(height: AppSpacing.sm),
          _Legend(hasPickup: hasPickup, hasDrop: hasDrop, hasDriver: hasDriver),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool hasPickup;
  final bool hasDrop;
  final bool hasDriver;

  const _Legend({required this.hasPickup, required this.hasDrop, required this.hasDriver});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hasPickup) ...[
          _Dot(color: const Color(0xFF4CAF50), label: 'Pickup'),
          const SizedBox(width: AppSpacing.md),
        ],
        if (hasDrop) ...[
          _Dot(color: const Color(0xFFF44336), label: 'Drop'),
          const SizedBox(width: AppSpacing.md),
        ],
        if (hasDriver)
          _Dot(color: const Color(0xFF1E88E5), label: 'Driver'),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2)),
      ],
    );
  }
}

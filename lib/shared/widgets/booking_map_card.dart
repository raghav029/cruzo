import 'package:flutter/material.dart';
import 'package:cruzo/core/di/injection.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'package:cruzo/core/maps/map_models.dart';
import 'package:cruzo/core/maps/map_service.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking.dart';
import 'cruzo_card.dart';

class BookingMapCard extends StatelessWidget {
  final Booking booking;

  const BookingMapCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (!booking.hasCoords) {
      return CruzoCard(
        title: 'Trip Route',
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: AppColors.darkFg3, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('Location unavailable', style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3)),
          ],
        ),
      );
    }

    final markers = <AppMarker>[
      AppMarker(
        id: 'pickup',
        position: AppLatLng(booking.pickupLat!, booking.pickupLng!),
        type: AppMarkerType.pickup,
        label: 'Pickup',
      ),
      AppMarker(
        id: 'drop',
        position: AppLatLng(booking.dropLat!, booking.dropLng!),
        type: AppMarkerType.drop,
        label: 'Drop',
      ),
      if (booking.hasDriverLocation)
        AppMarker(
          id: 'driver',
          position: AppLatLng(booking.driverCurrentLat!, booking.driverCurrentLng!),
          type: AppMarkerType.driver,
          label: booking.driverName ?? 'Driver',
        ),
    ];

    final mapSvc = getIt<MapService>();

    return CruzoCard(
      title: 'Trip Route',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mapSvc.buildMapWidget(markers: markers, height: 200),
          const SizedBox(height: AppSpacing.sm),
          _Legend(hasDriver: booking.hasDriverLocation),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool hasDriver;
  const _Legend({required this.hasDriver});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(color: const Color(0xFF4CAF50), label: 'Pickup'),
        const SizedBox(width: AppSpacing.md),
        _Dot(color: const Color(0xFFF44336), label: 'Drop'),
        if (hasDriver) ...[
          const SizedBox(width: AppSpacing.md),
          _Dot(color: const Color(0xFF2196F3), label: 'Driver'),
        ],
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

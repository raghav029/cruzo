import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cruzo/core/di/injection.dart';
import 'package:cruzo/core/maps/map_models.dart';
import 'package:cruzo/core/maps/google/google_map_service.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import '../../domain/live_trip.dart';
import '../../data/live_map_repository.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final _repo = getIt<LiveMapRepository>();
  final _mapService = getIt<GoogleMapService>();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<LiveTrip> _trips = [];
  LiveTrip? _selected;
  bool _loading = true;
  DateTime? _lastUpdated;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final trips = await _repo.getLiveTrips();
      final markers = await _buildMarkers(trips);
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _markers = markers;
        _lastUpdated = DateTime.now();
        _loading = false;
        if (_selected == null && trips.isNotEmpty) _selected = trips.first;
        if (_selected != null) {
          _selected = trips.firstWhere(
            (t) => t.bookingId == _selected!.bookingId,
            orElse: () => trips.isNotEmpty ? trips.first : _selected!,
          );
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Set<Marker>> _buildMarkers(List<LiveTrip> trips) async {
    final appMarkers = trips
        .where((t) => t.hasLocation)
        .map((t) => AppMarker(
              id: t.bookingId,
              position: AppLatLng(t.driverLat!, t.driverLng!),
              type: AppMarkerType.driver,
              label: t.driverName ?? t.vehicleName,
            ))
        .toList();
    return _mapService.buildGmMarkers(appMarkers);
  }

  void _selectTrip(LiveTrip trip) {
    setState(() => _selected = trip);
    if (trip.hasLocation && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(trip.driverLat!, trip.driverLng!),
          14,
        ),
      );
    }
  }

  String _timeAgo() {
    if (_lastUpdated == null) return '';
    final secs = DateTime.now().difference(_lastUpdated!).inSeconds;
    return '${secs}s ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: Column(
        children: [
          _Header(
            tripCount: _trips.length,
            loading: _loading,
            timeAgo: _lastUpdated != null ? _timeAgo() : null,
            onRefresh: _fetch,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(20.5937, 78.9629),
                      zoom: 5,
                    ),
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (c) => _mapController = c,
                  ),
                ),
                _SidePanel(
                  trips: _trips,
                  selected: _selected,
                  loading: _loading,
                  onSelect: _selectTrip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int tripCount;
  final bool loading;
  final String? timeAgo;
  final VoidCallback onRefresh;

  const _Header({
    required this.tripCount,
    required this.loading,
    required this.timeAgo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.darkBg0,
        border: Border(bottom: BorderSide(color: AppColors.darkLine)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text('Live trips', style: AppTextStyles.h3),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.good.withAlpha(30),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.good.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.good,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.good,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
          else ...[
            if (timeAgo != null)
              Text(
                '$tripCount active · updated $timeAgo',
                style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
              ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  size: 16, color: AppColors.darkFg2),
              onPressed: onRefresh,
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Side panel ────────────────────────────────────────────────────────────────

class _SidePanel extends StatelessWidget {
  final List<LiveTrip> trips;
  final LiveTrip? selected;
  final bool loading;
  final ValueChanged<LiveTrip> onSelect;

  const _SidePanel({
    required this.trips,
    required this.selected,
    required this.loading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppColors.darkBg0,
        border: Border(left: BorderSide(color: AppColors.darkLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected != null) _TripDetail(trip: selected!),
          if (selected != null) const Divider(height: 1, color: AppColors.darkLine),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : trips.isEmpty
                    ? Center(
                        child: Text(
                          'No active trips',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.darkFg3),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: trips.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) => _TripTile(
                          trip: trips[i],
                          isSelected:
                              selected?.bookingId == trips[i].bookingId,
                          onTap: () => onSelect(trips[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Trip detail ───────────────────────────────────────────────────────────────

class _TripDetail extends StatelessWidget {
  final LiveTrip trip;
  const _TripDetail({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.vehicleName, style: AppTextStyles.h4),
          if (trip.plateNumber != null)
            Text(
              trip.plateNumber!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.darkFg3,
                fontFamily: 'monospace',
              ),
            ),
          const SizedBox(height: 12),
          _Row('Passenger', trip.passengerName ?? '—'),
          const SizedBox(height: 6),
          _Row('Driver', trip.driverName ?? 'Unassigned'),
          if (trip.driverPhone != null) ...[
            const SizedBox(height: 6),
            _Row('Phone', trip.driverPhone!),
          ],
          const SizedBox(height: 12),
          _Row('From', trip.pickupAddress ?? '—'),
          const SizedBox(height: 6),
          _Row('To', trip.dropAddress ?? '—'),
          const SizedBox(height: 12),
          _Row(
            'GPS',
            trip.hasLocation
                ? '${trip.driverLat!.toStringAsFixed(5)}, ${trip.driverLng!.toStringAsFixed(5)}'
                : 'No signal',
          ),
          if (trip.locationUpdatedAt != null) ...[
            const SizedBox(height: 6),
            _Row('Updated', _formatTime(trip.locationUpdatedAt!)),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.caption),
        ),
      ],
    );
  }
}

// ── Trip tile ─────────────────────────────────────────────────────────────────

class _TripTile extends StatelessWidget {
  final LiveTrip trip;
  final bool isSelected;
  final VoidCallback onTap;

  const _TripTile({
    required this.trip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBg : AppColors.darkBg2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.darkLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.vehicleName,
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkFg0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: trip.hasLocation
                        ? AppColors.good
                        : AppColors.darkFg3,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              trip.driverName ?? 'No driver',
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
            ),
            if (trip.passengerName != null) ...[
              const SizedBox(height: 2),
              Text(
                trip.passengerName!,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

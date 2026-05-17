import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'package:cruzo/core/di/injection.dart';
import 'package:cruzo/shared/widgets/app_error_view.dart';
import 'package:cruzo/shared/widgets/app_empty_view.dart';
import 'package:cruzo/shared/widgets/filter_chip_row.dart';
import 'package:cruzo/shared/widgets/status_tag.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../view_models/trip_history_view_model.dart';

class DriverTripHistoryScreen extends StatefulWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  State<DriverTripHistoryScreen> createState() =>
      _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState extends State<DriverTripHistoryScreen> {
  final _scrollCtrl = ScrollController();
  late final TripHistoryViewModel _vm;

  static const _filters = [
    ('All', null),
    ('Completed', 'COMPLETED'),
    ('Cancelled', 'CANCELLED_BY_DRIVER'),
    ('In Progress', 'IN_PROGRESS'),
  ];

  @override
  void initState() {
    super.initState();
    _vm = getIt<TripHistoryViewModel>();
    _vm.load(reset: true);
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _vm.load();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadH,
                    AppSpacing.pagePadV,
                    AppSpacing.pagePadH,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Trip History',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.darkFg0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.darkFg2,
                        ),
                        onPressed: () => _vm.load(reset: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilterChipRow<String>(
                  selected: _vm.selectedStatus,
                  filters: _filters,
                  onTap: _vm.applyFilter,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_vm.isLoading && _vm.trips.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_vm.error != null && _vm.trips.isEmpty) {
      return AppErrorView(
        message: _vm.error!,
        onRetry: () => _vm.load(reset: true),
      );
    }
    if (_vm.trips.isEmpty) {
      return const AppEmptyView(
        icon: Icons.history_outlined,
        message: 'No trips found',
        subtitle: 'Your completed trips will appear here',
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.darkBg2,
      onRefresh: () => _vm.load(reset: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadH,
          vertical: AppSpacing.sm,
        ),
        itemCount: _vm.trips.length + (_vm.hasMore ? 1 : 0),
        separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (i == _vm.trips.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          return _TripHistoryCard(trip: _vm.trips[i]);
        },
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final Booking trip;
  const _TripHistoryCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final status = trip.statusEnum;
    final (statusColor, statusBg) = _statusColors(status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.employeeName ?? 'Passenger',
                  style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
                ),
              ),
              StatusTag(
                label: status.shortName,
                color: statusColor,
                bgColor: statusBg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _IconRow(Icons.location_on_outlined, trip.pickupAddress),
          const SizedBox(height: 4),
          _IconRow(Icons.flag_outlined, trip.dropAddress),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _IconRow(
                  Icons.access_time_outlined,
                  _formatDate(trip.scheduledAt),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (trip.finalFare != null)
                Text(
                  '₹${trip.finalFare!.toStringAsFixed(0)}',
                  style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                )
              else if (trip.estimatedFare != null)
                Text(
                  '~₹${trip.estimatedFare!.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.darkFg2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(BookingStatus status) => switch (status) {
    BookingStatus.completed => (AppColors.good, AppColors.goodBg),
    BookingStatus.inProgress => (AppColors.accent, AppColors.accentBg),
    BookingStatus.driverEnRoute => (AppColors.info, AppColors.infoBg),
    BookingStatus.arrived => (AppColors.warn, AppColors.warnBg),
    BookingStatus.cancelledByDriver ||
    BookingStatus.cancelledByEmployee ||
    BookingStatus.cancelledByAdmin ||
    BookingStatus.cancelledByFleetManager ||
    BookingStatus.rejected => (AppColors.bad, AppColors.badBg),
    _ => (AppColors.darkFg2, AppColors.darkBg3),
  };

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.darkFg3),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg1),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

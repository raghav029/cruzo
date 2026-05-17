import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_bloc.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_event.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_state.dart';
import 'employee_trip_detail_sheet.dart';

class EmployeeMyTripsScreen extends StatefulWidget {
  const EmployeeMyTripsScreen({super.key});

  @override
  State<EmployeeMyTripsScreen> createState() => _EmployeeMyTripsScreenState();
}

class _EmployeeMyTripsScreenState extends State<EmployeeMyTripsScreen> {
  BookingStatus? _filter;

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Pending', value: BookingStatus.pendingApproval),
    (label: 'Approved', value: BookingStatus.approved),
    (label: 'Active', value: BookingStatus.inProgress),
    (label: 'Done', value: BookingStatus.completed),
    (label: 'Cancelled', value: BookingStatus.cancelledByEmployee),
  ];

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      BookingLoadRequested(statusFilter: _filter?.rawValue),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                AppSpacing.sm,
              ),
              child: Text('My Trips', style: AppTextStyles.h1),
            ),

            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                children: _filters.map((f) {
                  final active = _filter == f.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filter = f.value);
                      context.read<BookingBloc>().add(
                        BookingLoadRequested(statusFilter: _filter?.rawValue),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.accent.withAlpha(30)
                            : AppColors.darkBg2,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: active ? AppColors.accent : AppColors.darkLine,
                        ),
                      ),
                      child: Text(
                        f.label,
                        style: AppTextStyles.bodySm.copyWith(
                          color: active ? AppColors.accent : AppColors.darkFg2,
                          fontWeight: active ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is BookingError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.bad,
                        ),
                      ),
                    );
                  }
                  if (state is BookingLoaded) {
                    if (state.bookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.darkFg3,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No trips found',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.darkFg3,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.darkBg2,
                      onRefresh: () async {
                        context.read<BookingBloc>().add(
                          BookingLoadRequested(statusFilter: _filter?.rawValue),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadH,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: state.bookings.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) =>
                            _TripCard(booking: state.bookings[i]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  const _TripCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.statusEnum;
    final statusColor = status.color;

    return GestureDetector(
      onTap: () => EmployeeTripDetailSheet.show(context, booking: booking),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadH),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    status.shortName,
                    style: AppTextStyles.caption.copyWith(color: statusColor),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(booking.scheduledAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _AddrRow(
              icon: Icons.my_location_rounded,
              text: booking.pickupAddress,
            ),
            const SizedBox(height: 4),
            _AddrRow(
              icon: Icons.location_on_rounded,
              text: booking.dropAddress,
            ),
            if (booking.vehicleTypeRequested != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.directions_car_rounded,
                    size: 13,
                    color: AppColors.darkFg3,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.vehicleTypeRequested!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg3,
                    ),
                  ),
                  if (booking.finalFare != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.currency_rupee,
                      size: 12,
                      color: AppColors.darkFg3,
                    ),
                    Text(
                      booking.finalFare!.toStringAsFixed(0),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg3,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      return '${dt.day} ${months[dt.month - 1]}, $h:$m $ampm';
    } catch (_) {
      return iso;
    }
  }
}

class _AddrRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AddrRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.darkFg3),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg1),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/app_error_view.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../bloc/driver_trip_bloc.dart';
import '../bloc/driver_trip_event.dart';
import '../bloc/driver_trip_state.dart';
import 'driver_booking_trip_screen.dart';
import 'driver_daily_trip_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    context.read<DriverTripBloc>().add(const DriverTripLoadRequested());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        title: Text('My Trips',
            style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
        actions: [
          BlocBuilder<DriverTripBloc, DriverTripState>(
            buildWhen: (p, c) => p.availability != c.availability || p.status != c.status,
            builder: (context, state) {
              final avail = state.availability;
              final isOnTrip = avail == 'ON_TRIP';
              final isAvailable = avail == 'AVAILABLE';
              final color = isAvailable ? AppColors.good : AppColors.darkFg3;
              final bg = isAvailable ? AppColors.goodBg : AppColors.darkBg3;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: GestureDetector(
                  onTap: isOnTrip || state.status == DriverTripStatus.actionInProgress
                      ? null
                      : () {
                          final next = isAvailable ? 'OFF_DUTY' : 'AVAILABLE';
                          context.read<DriverTripBloc>().add(DriverAvailabilityUpdated(next));
                        },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          avail.replaceAll('_', ' '),
                          style: AppTextStyles.caption.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<DriverTripBloc, DriverTripState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) => IconButton(
              icon: state.status == DriverTripStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    )
                  : const Icon(Icons.refresh, color: AppColors.darkFg1),
              onPressed: state.status == DriverTripStatus.loading
                  ? null
                  : () => context
                      .read<DriverTripBloc>()
                      .add(const DriverTripLoadRequested()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.darkFg2,
          tabs: const [
            Tab(text: 'Booking Trip'),
            Tab(text: 'Daily Trip'),
          ],
        ),
      ),
      body: BlocConsumer<DriverTripBloc, DriverTripState>(
        listenWhen: (p, c) =>
            c.actionError != null && p.actionError != c.actionError,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.bad,
            ),
          );
        },
        builder: (context, state) {
          if (state.status == DriverTripStatus.loading &&
              state.activeBooking == null &&
              state.dailyTrip == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (state.status == DriverTripStatus.error) {
            return AppErrorView(
              message: state.errorMessage ?? 'Failed to load trips',
              onRetry: () => context
                  .read<DriverTripBloc>()
                  .add(const DriverTripLoadRequested()),
            );
          }

          return TabBarView(
            controller: _tabs,
            children: [
              _BookingTripTab(state: state),
              _DailyTripTab(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _BookingTripTab extends StatelessWidget {
  final DriverTripState state;
  const _BookingTripTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.completedBooking != null) {
      return _TripCompletedView(booking: state.completedBooking!);
    }

    final booking = state.activeBooking;
    if (booking == null) {
      return RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.darkBg2,
        onRefresh: () async => context
            .read<DriverTripBloc>()
            .add(const DriverTripLoadRequested()),
        child: ListView(
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_outlined,
                        size: 64, color: AppColors.darkFg3),
                    const SizedBox(height: AppSpacing.md),
                    Text('No active booking',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Pull down to refresh',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.darkFg3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.darkBg2,
      onRefresh: () async => context
          .read<DriverTripBloc>()
          .add(const DriverTripLoadRequested()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: DriverBookingTripScreen(booking: booking),
      ),
    );
  }
}

class _TripCompletedView extends StatelessWidget {
  final Booking booking;
  const _TripCompletedView({required this.booking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.goodBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.good,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Trip Completed!', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Great job! The trip has been completed successfully.',
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.darkBg2,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.darkLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip Summary', style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0)),
                const SizedBox(height: AppSpacing.sm),
                _SummaryRow(Icons.person_outline, booking.employeeName ?? 'Passenger'),
                const SizedBox(height: AppSpacing.xs),
                _SummaryRow(Icons.my_location_rounded, booking.pickupAddress),
                const SizedBox(height: AppSpacing.xs),
                _SummaryRow(Icons.location_on_rounded, booking.dropAddress),
                if (booking.finalFare != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _SummaryRow(
                    Icons.currency_rupee,
                    '₹${booking.finalFare!.toStringAsFixed(0)}',
                    valueColor: AppColors.good,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.read<DriverTripBloc>().add(const DriverTripLoadRequested()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              child: Text('Done', style: AppTextStyles.body.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? valueColor;
  const _SummaryRow(this.icon, this.text, {this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: AppColors.darkFg3),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(color: valueColor ?? AppColors.darkFg1),
        ),
      ),
    ],
  );
}

class _DailyTripTab extends StatelessWidget {
  final DriverTripState state;
  const _DailyTripTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final trip = state.dailyTrip;
    if (trip == null) {
      return RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.darkBg2,
        onRefresh: () async => context
            .read<DriverTripBloc>()
            .add(const DriverTripLoadRequested()),
        child: ListView(
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route_outlined,
                        size: 64, color: AppColors.darkFg3),
                    const SizedBox(height: AppSpacing.md),
                    Text('No daily trip for today',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Pull down to refresh',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.darkFg3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.darkBg2,
      onRefresh: () async => context
          .read<DriverTripBloc>()
          .add(const DriverTripLoadRequested()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: DriverDailyTripScreen(trip: trip),
      ),
    );
  }
}

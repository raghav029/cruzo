import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_state.dart';
import '../../../../../core/auth/bloc/auth_event.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../employee/daily_schedule/presentation/bloc/employee_schedule_bloc.dart';
import '../../../../employee/daily_schedule/presentation/bloc/employee_schedule_event.dart';
import '../../../../employee/daily_schedule/presentation/bloc/employee_schedule_state.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_repo.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_bloc.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_event.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_state.dart';
import '../../../my_trips/presentation/screens/employee_trip_detail_sheet.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/result.dart';
import '../../../../fleet_manager/sos_alerts/domain/sos_alert_repo.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late Future<List<Booking>> _activeBookingFuture;

  @override
  void initState() {
    super.initState();
    _activeBookingFuture = _loadActiveBooking();
    context.read<BookingBloc>().add(const BookingLoadRequested());
    context.read<EmployeeScheduleBloc>().add(
      const EmployeeScheduleLoadRequested(),
    );
  }

  Future<List<Booking>> _loadActiveBooking() async {
    final result = await getIt<BookingRepo>().myActive();
    if (result is Success<List<Booking>>) return result.value;
    return [];
  }

  void _refreshActiveBooking() {
    setState(() {
      _activeBookingFuture = _loadActiveBooking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final userName = auth is AuthAuthenticated ? auth.name : 'Employee';

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.darkBg2,
          onRefresh: () async {
            _refreshActiveBooking();
            context.read<BookingBloc>().add(const BookingLoadRequested());
            context.read<EmployeeScheduleBloc>().add(
              const EmployeeScheduleLoadRequested(),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadH,
                    AppSpacing.pagePadV,
                    AppSpacing.pagePadH,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${_firstName(userName)} 👋',
                              style: AppTextStyles.h1,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'What do you need today?',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.darkFg2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.darkFg3,
                          size: 20,
                        ),
                        onPressed: () =>
                            context.read<AuthBloc>().add(AuthLogoutRequested()),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick actions
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.darkFg1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.add_circle_rounded,
                              label: 'Book a Ride',
                              color: AppColors.accent,
                              onTap: () =>
                                  context.go(AppRoutes.employeeBookRidePath),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.receipt_long_rounded,
                              label: 'My Trips',
                              color: AppColors.info,
                              onTap: () =>
                                  context.go(AppRoutes.employeeMyTripsPath),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _QuickAction(
                              icon: Icons.directions_bus_rounded,
                              label: 'Schedule',
                              color: AppColors.warn,
                              onTap: () => context.go(
                                AppRoutes.employeeDailySchedulePath,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // Active booking banner
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<List<Booking>>(
                    future: _activeBookingFuture,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
                      final booking = snap.data!.first;
                      final status = booking.statusEnum;
                      final isArrived = status == BookingStatus.arrived;
                      final isInProgress = status == BookingStatus.inProgress;
                      final showOtp = (isArrived && booking.boardingOtp != null) ||
                          (isInProgress && booking.dropOtp != null);
                      return GestureDetector(
                        onTap: () => EmployeeTripDetailSheet.show(context, booking: booking),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.accentBg,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(color: AppColors.accent.withAlpha(80)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.directions_car_rounded,
                                      color: AppColors.accent, size: 16),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text('Active Trip',
                                      style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: status.color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(AppRadii.pill),
                                    ),
                                    child: Text(status.shortName,
                                        style: AppTextStyles.caption
                                            .copyWith(color: status.color)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(booking.dropAddress,
                                  style: AppTextStyles.h4
                                      .copyWith(color: AppColors.darkFg0),
                                  overflow: TextOverflow.ellipsis),
                              if (showOtp) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBg1,
                                    borderRadius: BorderRadius.circular(AppRadii.sm),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isArrived ? 'Boarding OTP' : 'Drop OTP',
                                              style: AppTextStyles.caption
                                                  .copyWith(color: AppColors.darkFg3),
                                            ),
                                            Text(
                                              isArrived
                                                  ? booking.boardingOtp!
                                                  : booking.dropOtp!,
                                              style: AppTextStyles.h2.copyWith(
                                                color: isArrived
                                                    ? AppColors.accent
                                                    : AppColors.good,
                                                fontFamily: 'monospace',
                                                letterSpacing: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Show to driver',
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.darkFg3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (!showOtp) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  isArrived || isInProgress
                                      ? 'Tap to see OTP'
                                      : 'Tap for details',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.accent),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // SOS
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                sliver: SliverToBoxAdapter(child: _SosButton()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Today's trip card
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                sliver: SliverToBoxAdapter(
                  child:
                      BlocBuilder<EmployeeScheduleBloc, EmployeeScheduleState>(
                        builder: (context, state) {
                          if (state is EmployeeScheduleLoading) {
                            return const _SectionLoading(label: "Today's trip");
                          }
                          if (state is EmployeeScheduleLoaded &&
                              state.todayTrip != null) {
                            final trip = state.todayTrip!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Trip",
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.darkFg1,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _TodayTripCard(trip: trip),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

              // Recent trips
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadH,
                ),
                sliver: SliverToBoxAdapter(
                  child: BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, state) {
                      if (state is BookingLoading) {
                        return const _SectionLoading(label: 'Recent trips');
                      }
                      if (state is BookingLoaded) {
                        final recent = state.bookings.take(3).toList();
                        if (recent.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Trips',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.darkFg1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.go(AppRoutes.employeeMyTripsPath),
                                  child: Text(
                                    'See all',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...recent.map((b) => _RecentTripRow(booking: b)),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          ),
        ),
      ),
    );
  }

  String _firstName(String name) {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.darkLine),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg1),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTripCard extends StatelessWidget {
  final dynamic trip;
  const _TodayTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final status = BookingStatus.fromString(trip.status as String);
    final statusColor = status.color;

    return Container(
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
              Expanded(
                child: Text(
                  trip.scheduleName as String,
                  style: AppTextStyles.h4,
                ),
              ),
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
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (trip.scheduledPickupTime != null)
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: 'Pickup: ${trip.scheduledPickupTime}',
            ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            text: 'Drop: ${trip.dropAddress}',
          ),
          if (trip.driverName != null)
            _InfoRow(
              icon: Icons.person_rounded,
              text: 'Driver: ${trip.driverName}',
            ),
          if (trip.vehiclePlate != null)
            _InfoRow(
              icon: Icons.directions_car_rounded,
              text: trip.vehiclePlate as String,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.darkFg3),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTripRow extends StatelessWidget {
  final Booking booking;
  const _RecentTripRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.statusEnum;
    final statusColor = status.color;

    return GestureDetector(
      onTap: () => EmployeeTripDetailSheet.show(context, booking: booking),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.cardPadH),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.dropAddress,
                  style: AppTextStyles.h4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(booking.scheduledAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              status.shortName,
              style: AppTextStyles.caption.copyWith(color: statusColor),
            ),
          ),
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

class _SosButton extends StatefulWidget {
  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton> {
  bool _sending = false;

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.bad, size: 20),
            const SizedBox(width: 8),
            Text(
              'Send SOS Alert',
              style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
            ),
          ],
        ),
        content: Text(
          'This will immediately alert your fleet managers. Only use in an emergency.',
          style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Send SOS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    final res = await getIt<SosAlertRepo>().send(
      'SOS — employee needs immediate assistance',
    );
    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.isSuccess
              ? 'SOS sent. Help is on the way.'
              : 'Failed to send SOS. Try again.',
        ),
        backgroundColor: res.isSuccess ? AppColors.good : AppColors.bad,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _sending ? null : _confirm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.badBg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.bad.withAlpha(80)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_sending)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.bad,
                ),
              )
            else
              const Icon(Icons.sos_rounded, color: AppColors.bad, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _sending ? 'Sending...' : 'SOS Emergency Alert',
              style: AppTextStyles.body.copyWith(
                color: AppColors.bad,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  final String label;
  const _SectionLoading({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.h3.copyWith(color: AppColors.darkFg1)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.darkBg2,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

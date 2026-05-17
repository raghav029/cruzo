import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_state.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../domain/employee_trip.dart';
import '../bloc/employee_schedule_bloc.dart';
import '../bloc/employee_schedule_event.dart';
import '../bloc/employee_schedule_state.dart';

class EmployeeDailyScheduleScreen extends StatefulWidget {
  const EmployeeDailyScheduleScreen({super.key});

  @override
  State<EmployeeDailyScheduleScreen> createState() =>
      _EmployeeDailyScheduleScreenState();
}

class _EmployeeDailyScheduleScreenState
    extends State<EmployeeDailyScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<EmployeeScheduleBloc>()
        .add(const EmployeeScheduleLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.darkBg2,
          onRefresh: () async => context
              .read<EmployeeScheduleBloc>()
              .add(const EmployeeScheduleLoadRequested()),
          child: BlocConsumer<EmployeeScheduleBloc, EmployeeScheduleState>(
            listener: (context, state) {
              if (state is EmployeeScheduleSkipSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Day skipped successfully'),
                    backgroundColor: AppColors.good,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              if (state is EmployeeScheduleSkipError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.bad,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadH,
                        AppSpacing.pagePadV,
                        AppSpacing.pagePadH,
                        AppSpacing.md,
                      ),
                      child: Text('My Schedule', style: AppTextStyles.h1),
                    ),
                  ),
                  if (state is EmployeeScheduleLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2),
                      ),
                    )
                  else if (state is EmployeeScheduleError)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(state.message,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.bad)),
                      ),
                    )
                  else if (state is EmployeeScheduleLoaded) ...[
                    // Today's trip
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadH),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Trip",
                                style: AppTextStyles.h3
                                    .copyWith(color: AppColors.darkFg1)),
                            const SizedBox(height: AppSpacing.sm),
                            state.todayTrip != null
                                ? _TodayTripCard(
                                    trip: state.todayTrip!,
                                    userId: _userId(context),
                                    skipping:
                                        state is EmployeeScheduleSkipping,
                                    onSkip: (pid) => _confirmSkip(
                                        context, pid, _todayStr()),
                                  )
                                : _EmptyCard(
                                    message: 'No trip scheduled for today'),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.lg)),

                    // Upcoming
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadH),
                      sliver: SliverToBoxAdapter(
                        child: Text('Upcoming Trips',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.darkFg1)),
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sm)),
                    if (state.upcoming.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pagePadH),
                          child: _EmptyCard(
                              message:
                                  'Not enrolled in any recurring schedule'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pagePadH),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _UpcomingTripCard(
                                trip: state.upcoming[i],
                                userId: _userId(context),
                                onSkip: (pid, date) =>
                                    _confirmSkip(context, pid, date),
                              ),
                            ),
                            childCount: state.upcoming.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _userId(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.userId : '';
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmSkip(
      BuildContext context, String passengerId, String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: Text('Skip this day?', style: AppTextStyles.h3),
        content: Text(
          'You will be marked as skipped for $date.',
          style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Skip',
                style: AppTextStyles.body.copyWith(color: AppColors.bad)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<EmployeeScheduleBloc>().add(
            EmployeeScheduleSkipRequested(passengerId, date),
          );
    }
  }
}

class _TodayTripCard extends StatelessWidget {
  final EmployeeTrip trip;
  final String userId;
  final bool skipping;
  final void Function(String passengerId) onSkip;

  const _TodayTripCard({
    required this.trip,
    required this.userId,
    required this.skipping,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final myPassenger = trip.myPassenger(userId);
    final statusColor = _tripStatusColor(trip.status);

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
                child: Text(trip.scheduleName, style: AppTextStyles.h4),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  trip.status.replaceAll('_', ' '),
                  style: AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (trip.scheduledPickupTime != null)
            _InfoRow(
                icon: Icons.access_time_rounded,
                text: 'Pickup: ${trip.scheduledPickupTime}'),
          _InfoRow(
              icon: Icons.location_on_rounded,
              text: 'Drop: ${trip.dropAddress}'),
          if (trip.driverName != null)
            _InfoRow(
                icon: Icons.person_rounded,
                text: 'Driver: ${trip.driverName}${trip.driverPhone != null ? ' · ${trip.driverPhone}' : ''}'),
          if (trip.vehiclePlate != null)
            _InfoRow(
                icon: Icons.directions_car_rounded,
                text: trip.vehiclePlate!),

          // OTP section
          if (myPassenger != null && myPassenger.boardingOtp != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Boarding OTP',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.darkFg3)),
                      Text(myPassenger.boardingOtp!,
                          style: AppTextStyles.h2
                              .copyWith(color: AppColors.accent,
                                  letterSpacing: 4)),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Skip button
          if (myPassenger != null &&
              myPassenger.status == 'PENDING' &&
              trip.status == 'SCHEDULED') ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: skipping ? null : () => onSkip(myPassenger.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bad,
                  side: const BorderSide(color: AppColors.bad),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm)),
                ),
                child: skipping
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: AppColors.bad, strokeWidth: 2))
                    : const Text('Skip Today'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingTripCard extends StatelessWidget {
  final EmployeeTrip trip;
  final String userId;
  final void Function(String passengerId, String date) onSkip;

  const _UpcomingTripCard({
    required this.trip,
    required this.userId,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final myPassenger = trip.myPassenger(userId);
    final statusColor = _tripStatusColor(trip.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadH),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.scheduleName, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  trip.tripDate,
                  style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
                ),
                const SizedBox(height: 2),
                Text(
                  trip.dropAddress,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  trip.status.replaceAll('_', ' '),
                  style:
                      AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ),
              if (myPassenger != null &&
                  myPassenger.status == 'PENDING') ...[
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () => onSkip(myPassenger.id, trip.tripDate),
                  child: Text('Skip',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.bad)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Center(
        child: Text(message,
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg3)),
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
            child: Text(text,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

Color _tripStatusColor(String s) => switch (s) {
      'IN_PROGRESS' => AppColors.good,
      'COMPLETED' => AppColors.darkFg3,
      'CANCELLED' => AppColors.bad,
      _ => AppColors.warn,
    };

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../../domain/driver_daily_trip.dart';
import '../bloc/driver_trip_bloc.dart';
import '../bloc/driver_trip_event.dart';
import '../bloc/driver_trip_state.dart';

class DriverDailyTripScreen extends StatelessWidget {
  final DriverDailyTrip trip;
  const DriverDailyTripScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverTripBloc, DriverTripState>(
      listener: (context, state) {
        if (state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.bad,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TripHeader(trip: trip),
          const SizedBox(height: AppSpacing.md),
          ...trip.passengers.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PassengerCard(trip: trip, passenger: p),
            ),
          ),
          if (trip.isScheduled) ...[
            const SizedBox(height: AppSpacing.sm),
            _StartTripButton(trip: trip),
          ],
          if (trip.isInProgress) ...[
            const SizedBox(height: AppSpacing.sm),
            _CompleteTripButton(trip: trip),
          ],
        ],
      ),
    );
  }
}

class _TripHeader extends StatelessWidget {
  final DriverDailyTrip trip;
  const _TripHeader({required this.trip});

  @override
  Widget build(BuildContext context) {
    return _DriverCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.scheduleName,
                  style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
                ),
              ),
              _TripStatusChip(trip.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Date: ${trip.tripDate}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
          ),
          if (trip.scheduledPickupTime != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pickup: ${trip.scheduledPickupTime}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 14,
                color: AppColors.darkFg3,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  trip.dropAddress,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.darkFg1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${trip.passengers.length} passenger${trip.passengers.length != 1 ? 's' : ''}',
            style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
          ),
        ],
      ),
    );
  }
}

class _PassengerCard extends StatefulWidget {
  final DriverDailyTrip trip;
  final DriverDailyTripPassenger passenger;
  const _PassengerCard({required this.trip, required this.passenger});

  @override
  State<_PassengerCard> createState() => _PassengerCardState();
}

class _PassengerCardState extends State<_PassengerCard> {
  final _ctrl = TextEditingController();
  bool _showOtp = false;
  bool _isDropMode = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submitOtp(BuildContext context) {
    if (_ctrl.text.trim().isEmpty) return;
    if (_isDropMode) {
      context.read<DriverTripBloc>().add(
        DriverDailyTripPassengerDropped(
          widget.trip.id,
          widget.passenger.id,
          _ctrl.text.trim(),
        ),
      );
    } else {
      context.read<DriverTripBloc>().add(
        DriverDailyTripPassengerBoarded(
          widget.trip.id,
          widget.passenger.id,
          _ctrl.text.trim(),
        ),
      );
    }
    setState(() {
      _showOtp = false;
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.passenger;
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final loading = state.status == DriverTripStatus.actionInProgress;

        return _DriverCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      '${p.stopSequence}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.employeeName,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.darkFg0,
                          ),
                        ),
                        if (p.employeePhone != null)
                          Text(
                            p.employeePhone!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.darkFg2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _statusChip(p.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.darkFg3,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      p.pickupAddress,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg2,
                      ),
                    ),
                  ),
                ],
              ),
              if (!p.isTerminal) ...[
                const SizedBox(height: AppSpacing.sm),
                if (_showOtp) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.darkFg0,
                          ),
                          decoration: InputDecoration(
                            hintText: _isDropMode ? 'Drop OTP' : 'Boarding OTP',
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.darkFg3,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.darkBg3,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              borderSide: const BorderSide(
                                color: AppColors.darkLine,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              borderSide: const BorderSide(
                                color: AppColors.darkLine,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton(
                        onPressed: loading ? null : () => _submitOtp(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _showOtp = false;
                          _ctrl.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.darkLine),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.darkFg2,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      if (p.isPending) ...[
                        _ActionChip(
                          label: 'Board',
                          color: AppColors.good,
                          onTap: () => setState(() {
                            _isDropMode = false;
                            _showOtp = true;
                          }),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ActionChip(
                          label: 'No Show',
                          color: AppColors.bad,
                          onTap: loading
                              ? null
                              : () => context.read<DriverTripBloc>().add(
                                  DriverDailyTripPassengerNoShow(
                                    widget.trip.id,
                                    p.id,
                                  ),
                                ),
                        ),
                      ],
                      if (p.isBoarded)
                        _ActionChip(
                          label: 'Drop',
                          color: AppColors.accent,
                          onTap: () => setState(() {
                            _isDropMode = true;
                            _showOtp = true;
                          }),
                        ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    final (color, bg) = switch (status) {
      'PENDING' => (AppColors.warn, AppColors.warnBg),
      'BOARDED' => (AppColors.accent, AppColors.accentBg),
      'DROPPED' => (AppColors.good, AppColors.goodBg),
      'NO_SHOW' => (AppColors.bad, AppColors.badBg),
      'SKIPPED' => (AppColors.darkFg3, AppColors.darkBg3),
      _ => (AppColors.darkFg2, AppColors.darkBg2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(status, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
      ),
    );
  }
}

class _CompleteTripButton extends StatelessWidget {
  final DriverDailyTrip trip;
  const _CompleteTripButton({required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final loading = state.status == DriverTripStatus.actionInProgress;
        final allTerminal = trip.passengers.every((p) => p.isTerminal);
        if (!allTerminal) return const SizedBox.shrink();

        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: loading
                ? null
                : () => context.read<DriverTripBloc>().add(
                    DriverDailyTripCompleted(trip.id),
                  ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.good,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Complete Daily Trip',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
          ),
        );
      },
    );
  }
}

class _StartTripButton extends StatelessWidget {
  final DriverDailyTrip trip;
  const _StartTripButton({required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final loading = state.status == DriverTripStatus.actionInProgress;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: loading
                ? null
                : () => context.read<DriverTripBloc>().add(
                    DriverDailyTripStarted(trip.id),
                  ),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, color: Colors.black),
            label: Text(
              'Start Trip',
              style: AppTextStyles.body.copyWith(color: Colors.black),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Widget child;
  const _DriverCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.darkBg2,
      borderRadius: BorderRadius.circular(AppRadii.md),
      border: Border.all(color: AppColors.darkLine),
    ),
    child: child,
  );
}

class _TripStatusChip extends StatelessWidget {
  final BookingStatus status;
  const _TripStatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      BookingStatus.scheduled => (AppColors.warn, AppColors.warnBg),
      BookingStatus.inProgress => (AppColors.accent, AppColors.accentBg),
      BookingStatus.completed => (AppColors.good, AppColors.goodBg),
      BookingStatus.cancelled => (AppColors.bad, AppColors.badBg),
      _ => (AppColors.darkFg2, AppColors.darkBg2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}

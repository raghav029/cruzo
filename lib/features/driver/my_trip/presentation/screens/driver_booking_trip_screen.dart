import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../bloc/driver_trip_bloc.dart';
import '../bloc/driver_trip_event.dart';
import '../bloc/driver_trip_state.dart';

class DriverBookingTripScreen extends StatelessWidget {
  final Booking booking;
  const DriverBookingTripScreen({super.key, required this.booking});

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
          _TripInfoCard(booking: booking),
          const SizedBox(height: AppSpacing.md),
          _ActionButtons(booking: booking),
        ],
      ),
    );
  }
}

class _TripInfoCard extends StatelessWidget {
  final Booking booking;
  const _TripInfoCard({required this.booking});

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
                  booking.employeeName ?? 'Unknown Passenger',
                  style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
                ),
              ),
              _StatusChip(booking.statusEnum),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(Icons.location_on_outlined, 'Pickup', booking.pickupAddress),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(Icons.flag_outlined, 'Drop', booking.dropAddress),
          if (booking.vehiclePlate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(Icons.directions_car, 'Vehicle', booking.vehiclePlate!),
          ],
          if (booking.estimatedFare != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              Icons.currency_rupee,
              'Fare',
              '₹${booking.estimatedFare!.toStringAsFixed(0)}',
            ),
          ],
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(Icons.notes_outlined, 'Notes', booking.notes!),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.darkFg3),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg0),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Booking booking;
  const _ActionButtons({required this.booking});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripBloc, DriverTripState>(
      builder: (context, state) {
        final loading = state.status == DriverTripStatus.actionInProgress;

        return switch (booking.statusEnum) {
          BookingStatus.driverAssigned => Column(
            children: [
              _PrimaryButton(
                label: 'Start Driving (En Route)',
                loading: loading,
                onTap: () => context.read<DriverTripBloc>().add(
                  DriverTripStatusUpdated(booking.id, 'EN_ROUTE'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CancelButton(bookingId: booking.id, loading: loading),
            ],
          ),
          BookingStatus.driverEnRoute => Column(
            children: [
              _PrimaryButton(
                label: 'I Have Arrived',
                loading: loading,
                onTap: () => context.read<DriverTripBloc>().add(
                  DriverTripStatusUpdated(booking.id, 'ARRIVED'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CancelButton(bookingId: booking.id, loading: loading),
            ],
          ),
          BookingStatus.arrived => _OtpVerifyButton(
            booking: booking,
            loading: loading,
            title: 'Enter Boarding OTP',
            onVerify: (otp) => context.read<DriverTripBloc>().add(
              DriverTripBoardingOtpVerified(booking.id, otp),
            ),
          ),
          BookingStatus.inProgress => _OtpVerifyButton(
            booking: booking,
            loading: loading,
            title: 'Enter Drop OTP',
            onVerify: (otp) => context.read<DriverTripBloc>().add(
              DriverTripDropOtpVerified(booking.id, otp),
            ),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
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
                label,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}

class _OtpVerifyButton extends StatefulWidget {
  final Booking booking;
  final bool loading;
  final String title;
  final void Function(String otp) onVerify;
  const _OtpVerifyButton({
    required this.booking,
    required this.loading,
    required this.title,
    required this.onVerify,
  });

  @override
  State<_OtpVerifyButton> createState() => _OtpVerifyButtonState();
}

class _OtpVerifyButtonState extends State<_OtpVerifyButton> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().length < 4) return;
    widget.onVerify(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _DriverCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.darkFg3,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.darkBg3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide: const BorderSide(color: AppColors.darkLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide: const BorderSide(color: AppColors.darkLine),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: widget.loading ? null : _submit,
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
                child: widget.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final String bookingId;
  final bool loading;
  const _CancelButton({required this.bookingId, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: loading
            ? null
            : () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.darkBg2,
                  title: Text(
                    'Cancel Trip',
                    style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
                  ),
                  content: Text(
                    'Are you sure you want to cancel this trip?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.darkFg1,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'No',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.darkFg2,
                        ),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.bad,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<DriverTripBloc>().add(
                          DriverTripCancelled(bookingId),
                        );
                      },
                      child: const Text('Cancel Trip'),
                    ),
                  ],
                ),
              ),
        icon: const Icon(Icons.cancel_outlined, color: AppColors.bad, size: 18),
        label: Text(
          'Cancel Trip',
          style: AppTextStyles.body.copyWith(color: AppColors.bad),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.bad),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
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

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      BookingStatus.driverAssigned => (AppColors.warn, AppColors.warnBg),
      BookingStatus.driverEnRoute => (AppColors.info, AppColors.infoBg),
      BookingStatus.arrived => (AppColors.accent, AppColors.accentBg),
      BookingStatus.inProgress => (AppColors.good, AppColors.goodBg),
      BookingStatus.completed => (AppColors.good, AppColors.goodBg),
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
        status.shortName,
        style: AppTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}

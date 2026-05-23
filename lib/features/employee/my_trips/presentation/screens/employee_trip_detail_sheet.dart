import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/network/result.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_repo.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_bloc.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_event.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_state.dart';
import '../../../../fleet_manager/bookings/presentation/view_models/booking_detail_view_model.dart';

class EmployeeTripDetailSheet extends StatefulWidget {
  final Booking booking;

  const EmployeeTripDetailSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, {required Booking booking}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BookingBloc>(),
        child: EmployeeTripDetailSheet(booking: booking),
      ),
    );
  }

  @override
  State<EmployeeTripDetailSheet> createState() =>
      _EmployeeTripDetailSheetState();
}

class _EmployeeTripDetailSheetState extends State<EmployeeTripDetailSheet> {
  late final BookingDetailViewModel _vm;

  Booking get _booking => _vm.booking;

  @override
  void initState() {
    super.initState();
    _vm = getIt<BookingDetailViewModel>();
    _vm.init(widget.booking);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBg3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'My Trip',
                      style: AppTextStyles.h3.copyWith(
                          color: AppColors.darkFg0),
                    ),
                    const Spacer(),
                    _StatusBadge(status: _booking.statusEnum),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // OTP section — most important, shown first when active
                      if (_booking.statusEnum == BookingStatus.arrived &&
                          _booking.boardingOtp != null) ...[
                        _OtpHighlight(
                          label: 'Boarding OTP',
                          otp: _booking.boardingOtp!,
                          instruction:
                              'Show this to your driver when they arrive',
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 8),
                        _RefreshOtpButton(
                          bookingId: _booking.id,
                          onRefreshed: (updated) => _vm.init(updated),
                        ),
                        const SizedBox(height: 16),
                      ] else if (_booking.statusEnum ==
                              BookingStatus.inProgress &&
                          _booking.dropOtp != null) ...[
                        _OtpHighlight(
                          label: 'Drop OTP',
                          otp: _booking.dropOtp!,
                          instruction:
                              'Share this with your driver at your destination',
                          color: AppColors.good,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Driver info when assigned
                      if (_booking.driverName != null) ...[
                        _Section(
                          title: 'Driver',
                          child: _DriverInfo(booking: _booking),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Trip details
                      _Section(
                        title: 'Trip Details',
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.my_location_rounded,
                              label: 'Pickup',
                              value: _booking.pickupAddress,
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              icon: Icons.location_on_rounded,
                              label: 'Drop',
                              value: _booking.dropAddress,
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              icon: Icons.access_time_rounded,
                              label: 'Scheduled',
                              value: _fmtDt(_booking.scheduledAt),
                            ),
                            if (_booking.vehicleTypeRequested != null) ...[
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.directions_car_rounded,
                                label: 'Vehicle',
                                value: _booking.vehicleTypeRequested!,
                              ),
                            ],
                            if (_booking.notes != null) ...[
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.notes_rounded,
                                label: 'Notes',
                                value: _booking.notes!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Fare
                      if (_booking.estimatedFare != null ||
                          _booking.finalFare != null) ...[
                        const SizedBox(height: 16),
                        _Section(
                          title: 'Fare',
                          child: Column(
                            children: [
                              if (_booking.finalFare != null)
                                _InfoRow(
                                  icon: Icons.currency_rupee_rounded,
                                  label: 'Final Fare',
                                  value:
                                      '₹${_booking.finalFare!.toStringAsFixed(2)}',
                                )
                              else if (_booking.estimatedFare != null)
                                _InfoRow(
                                  icon: Icons.currency_rupee_rounded,
                                  label: 'Estimated',
                                  value:
                                      '₹${_booking.estimatedFare!.toStringAsFixed(2)}',
                                ),
                            ],
                          ),
                        ),
                      ],

                      // Rejection / cancellation reason
                      if (_booking.rejectionReason != null) ...[
                        const SizedBox(height: 16),
                        _ReasonBanner(
                          icon: Icons.cancel_outlined,
                          label: 'Rejection Reason',
                          reason: _booking.rejectionReason!,
                          color: AppColors.bad,
                        ),
                      ],
                      if (_booking.cancellationReason != null) ...[
                        const SizedBox(height: 16),
                        _ReasonBanner(
                          icon: Icons.info_outline,
                          label: 'Cancellation Reason',
                          reason: _booking.cancellationReason!,
                          color: AppColors.warn,
                        ),
                      ],

                      // Cancel button
                      if (_booking.statusEnum == BookingStatus.pendingApproval ||
                          _booking.statusEnum == BookingStatus.approved) ...[
                        const SizedBox(height: 24),
                        _CancelButton(booking: _booking),
                      ],

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
    } catch (_) {
      return iso;
    }
  }
}

// ── OTP highlight card ────────────────────────────────────────────────────────

class _OtpHighlight extends StatelessWidget {
  final String label;
  final String otp;
  final String instruction;
  final Color color;

  const _OtpHighlight({
    required this.label,
    required this.otp,
    required this.instruction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_open_rounded, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            otp,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: 12,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            instruction,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: otp));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy_rounded, size: 13, color: color.withAlpha(180)),
                const SizedBox(width: 4),
                Text(
                  'Copy OTP',
                  style: AppTextStyles.caption.copyWith(
                      color: color.withAlpha(180)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Driver info ───────────────────────────────────────────────────────────────

class _DriverInfo extends StatelessWidget {
  final Booking booking;
  const _DriverInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accentBg,
          child: Text(
            booking.driverName![0].toUpperCase(),
            style: AppTextStyles.h3.copyWith(color: AppColors.accent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.driverName!,
                style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
              ),
              if (booking.vehiclePlate != null)
                Text(
                  booking.vehiclePlate!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg3,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              if (booking.driverPhone != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 13, color: AppColors.darkFg3),
                    const SizedBox(width: 4),
                    Text(
                      booking.driverPhone!,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.darkFg1),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (booking.vehicleTypeRequested != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkBg3,
              borderRadius: BorderRadius.circular(AppRadii.xs),
            ),
            child: Text(
              booking.vehicleTypeRequested!,
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
            ),
          ),
      ],
    );
  }
}

// ── Cancel button ─────────────────────────────────────────────────────────────

class _CancelButton extends StatefulWidget {
  final Booking booking;
  const _CancelButton({required this.booking});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingMutationSuccess || state is BookingError) {
          Navigator.pop(context);
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _confirmCancel(context),
          icon: const Icon(Icons.cancel_outlined, color: AppColors.bad),
          label: Text(
            'Cancel Booking',
            style: AppTextStyles.body.copyWith(color: AppColors.bad),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.bad),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: Text(
          'Cancel Booking',
          style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this booking?',
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonCtrl,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
                filled: true,
                fillColor: AppColors.darkBg1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.darkLine),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.darkLine),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Keep',
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Navigator.pop(dialogCtx);
              context.read<BookingBloc>().add(
                BookingCancelRequested(
                  widget.booking.id,
                  reason: reason.isEmpty ? null : reason,
                ),
              );
            },
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

// ── Shared section wrapper ────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadH),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkFg3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.darkFg3),
        const SizedBox(width: 8),
        Text(
          '$label  ',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg0),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.caption.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReasonBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final String reason;
  final Color color;
  const _ReasonBanner({
    required this.icon,
    required this.label,
    required this.reason,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadH),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        AppTextStyles.label.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(reason,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.darkFg1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshOtpButton extends StatefulWidget {
  final String bookingId;
  final void Function(Booking updated) onRefreshed;

  const _RefreshOtpButton({
    required this.bookingId,
    required this.onRefreshed,
  });

  @override
  State<_RefreshOtpButton> createState() => _RefreshOtpButtonState();
}

class _RefreshOtpButtonState extends State<_RefreshOtpButton> {
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final result =
        await getIt<BookingRepo>().refreshBoardingOtp(widget.bookingId);
    if (!mounted) return;
    setState(() => _loading = false);
    switch (result) {
      case Success(:final value):
        widget.onRefreshed(value);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _loading ? null : _refresh,
        icon: _loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Refresh OTP'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTextStyles.bodySm,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
    );
  }
}

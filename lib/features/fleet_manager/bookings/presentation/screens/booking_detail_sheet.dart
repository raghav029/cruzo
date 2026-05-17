import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_state.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/booking_map_card.dart';
import '../../domain/booking.dart';
import '../../domain/booking_status.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../view_models/booking_detail_view_model.dart';
import '../view_models/assign_driver_view_model.dart';

class BookingDetailSheet extends StatefulWidget {
  final Booking booking;
  final bool openAssign;

  const BookingDetailSheet({
    super.key,
    required this.booking,
    this.openAssign = false,
  });

  static Future<void> show(
    BuildContext context, {
    required Booking booking,
    bool openAssign = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BookingBloc>(),
        child: BookingDetailSheet(booking: booking, openAssign: openAssign),
      ),
    );
  }

  @override
  State<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<BookingDetailSheet> {
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

  String _fmt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
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
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => DraggableScrollableSheet(
      initialChildSize: widget.openAssign ? 0.85 : 0.75,
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
                    'Booking Details',
                    style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
                  ),
                  const Spacer(),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_booking.hasCoords || _booking.hasDriverLocation) ...[
                      BookingMapCard(booking: _booking),
                      const SizedBox(height: 16),
                    ],
                    _Section(
                      title: 'Trip',
                      children: [
                        _Row('Client', _booking.corporateClientName ?? '—'),
                        _Row('Employee', _booking.employeeName ?? '—'),
                        _Row('Pickup', _booking.pickupAddress),
                        _Row('Drop', _booking.dropAddress),
                        _Row('Scheduled', _fmt(_booking.scheduledAt)),
                        _Row('Type', _booking.vehicleTypeRequested ?? '—'),
                        if (_booking.notes != null)
                          _Row('Notes', _booking.notes!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Status & Fare',
                      children: [
                        _Row('Status', _booking.statusEnum.displayName),
                        if (_booking.estimatedFare != null)
                          _Row(
                            'Est. Fare',
                            '₹${_booking.estimatedFare!.toStringAsFixed(2)}',
                          ),
                        if (_booking.finalFare != null)
                          _Row(
                            'Final Fare',
                            '₹${_booking.finalFare!.toStringAsFixed(2)}',
                          ),
                        if (_booking.rejectionReason != null)
                          _Row('Rejection Reason', _booking.rejectionReason!),
                        if (_booking.cancellationReason != null)
                          _Row(
                            'Cancellation Reason',
                            _booking.cancellationReason!,
                          ),
                      ],
                    ),
                    if (_booking.driverName != null) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Assignment',
                        children: [
                          _Row('Driver', _booking.driverName!),
                          if (_booking.vehiclePlate != null)
                            _Row('Vehicle', _booking.vehiclePlate!),
                        ],
                      ),
                    ],
                    if ((_booking.boardingOtp != null ||
                            _booking.dropOtp != null) &&
                        _booking.statusEnum.isDriverMoving) ...[
                      const SizedBox(height: 16),
                      _OtpCard(booking: _booking),
                    ],
                    const SizedBox(height: 16),
                    _StatusTimeline(booking: _booking),
                    if (widget.openAssign && _booking.isApproved &&
                        context.read<AuthBloc>().state is AuthAuthenticated &&
                        (context.read<AuthBloc>().state as AuthAuthenticated).role == AppRole.fleetManager) ...[
                      const SizedBox(height: 20),
                      _AssignDriverPanel(booking: _booking),
                    ],
                    if (!widget.openAssign &&
                        (_booking.isPending || _booking.isApproved)) ...[
                      const SizedBox(height: 20),
                      _ActionButtons(booking: _booking),
                    ],
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
}

class _AssignDriverPanel extends StatefulWidget {
  final Booking booking;
  const _AssignDriverPanel({required this.booking});

  @override
  State<_AssignDriverPanel> createState() => _AssignDriverPanelState();
}

class _AssignDriverPanelState extends State<_AssignDriverPanel> {
  String? _selectedDriverId;
  String? _selectedDriverName;
  String? _selectedVehicleId;
  String? _selectedVehiclePlate;
  late final AssignDriverViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<AssignDriverViewModel>();
    _vm.load(widget.booking);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _assign() {
    if (_selectedDriverId == null || _selectedVehicleId == null) return;
    context.read<BookingBloc>().add(
      BookingAssignDriverRequested(
        widget.booking.id,
        _selectedDriverId!,
        _selectedVehicleId!,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
    if (_vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign Driver & Vehicle',
          style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
        ),
        const SizedBox(height: 14),
        Text(
          'Available Drivers',
          style: AppTextStyles.label.copyWith(color: AppColors.darkFg2),
        ),
        const SizedBox(height: 8),
        if (_vm.drivers.isEmpty)
          _emptyChip('No available drivers')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vm.drivers.map((d) {
              final selected = _selectedDriverId == d['id'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDriverId = d['id'];
                  _selectedDriverName = d['name'];
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.darkLine,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['name']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.accentFg
                              : AppColors.darkFg0,
                        ),
                      ),
                      Text(
                        d['phone']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.darkFg2
                              : AppColors.darkFg2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        Text(
          'Available Vehicles',
          style: AppTextStyles.label.copyWith(color: AppColors.darkFg2),
        ),
        const SizedBox(height: 8),
        if (_vm.vehicles.isEmpty)
          _emptyChip('No available vehicles')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vm.vehicles.map((v) {
              final selected = _selectedVehicleId == v['id'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedVehicleId = v['id'];
                  _selectedVehiclePlate = v['plate'];
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.darkLine,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['plate']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.accentFg
                              : AppColors.darkFg0,
                        ),
                      ),
                      Text(
                        v['type']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.darkFg2
                              : AppColors.darkFg2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selectedDriverId != null && _selectedVehicleId != null
                ? _assign
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.darkBg3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Text(
              _selectedDriverId != null && _selectedVehicleId != null
                  ? 'Assign $_selectedDriverName • $_selectedVehiclePlate'
                  : 'Select driver and vehicle',
              style: TextStyle(
                color: _selectedDriverId != null
                    ? AppColors.accentFg
                    : AppColors.darkFg3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      );
      },
    );
  }

  Widget _emptyChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.darkBg3,
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: Text(text, style: AppTextStyles.caption),
  );
}

class _ActionButtons extends StatelessWidget {
  final Booking booking;
  const _ActionButtons({required this.booking});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final isFleetManager = auth is AuthAuthenticated &&
        auth.role == AppRole.fleetManager;

    if (booking.isPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                final reasonCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Reject Booking'),
                    content: TextField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Reason (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dCtx);
                          context.read<BookingBloc>().add(
                            BookingRejectRequested(
                              booking.id,
                              reason: reasonCtrl.text.trim().isEmpty
                                  ? null
                                  : reasonCtrl.text.trim(),
                            ),
                          );
                        },
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: AppColors.bad),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bad,
                side: const BorderSide(color: AppColors.bad),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BookingBloc>().add(
                  BookingApproveRequested(booking.id),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.good,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: AppColors.accentFg),
              ),
            ),
          ),
        ],
      );
    }

    if (booking.isApproved && isFleetManager) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<BookingBloc>().add(
                  BookingAutoAssignRequested(booking.id),
                );
              },
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Auto-Assign Driver'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => BookingDetailSheet.show(
                context,
                booking: booking,
                openAssign: true,
              ),
              icon: const Icon(Icons.person_pin_outlined),
              label: const Text('Manual Assign'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _OtpCard extends StatelessWidget {
  final Booking booking;
  const _OtpCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.lock_outline, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'Your OTPs — Share only with driver',
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (booking.boardingOtp != null)
                Expanded(
                  child: _OtpTile(
                    label: 'Boarding OTP',
                    otp: booking.boardingOtp!,
                  ),
                ),
              if (booking.boardingOtp != null && booking.dropOtp != null)
                const SizedBox(width: 12),
              if (booking.dropOtp != null)
                Expanded(
                  child: _OtpTile(label: 'Drop OTP', otp: booking.dropOtp!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpTile extends StatelessWidget {
  final String label;
  final String otp;
  const _OtpTile({required this.label, required this.otp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: otp));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.accent.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  otp,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.copy_outlined,
                  size: 14,
                  color: AppColors.darkFg3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(color: AppColors.darkFg2),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Booking booking;
  const _StatusTimeline({required this.booking});

  static const _steps = [
    (BookingStatus.pendingApproval, 'Pending', Icons.pending_outlined),
    (BookingStatus.approved, 'Approved', Icons.check_circle_outline),
    (BookingStatus.driverAssigned, 'Assigned', Icons.person_pin_outlined),
    (BookingStatus.driverEnRoute, 'En Route', Icons.directions_car_outlined),
    (BookingStatus.arrived, 'Arrived', Icons.location_on_outlined),
    (BookingStatus.inProgress, 'In Progress', Icons.play_circle_outline),
    (BookingStatus.completed, 'Completed', Icons.flag_outlined),
  ];

  int _currentIndex() {
    for (var i = 0; i < _steps.length; i++) {
      if (_steps[i].$1 == booking.statusEnum) return i;
    }
    return booking.isCancelled ? -1 : 0;
  }

  String? _tsFor(int idx) {
    return switch (idx) {
      1 => booking.approvedAt,
      2 => booking.driverAssignedAt,
      5 => booking.tripStartedAt,
      6 => booking.tripCompletedAt,
      _ => null,
    };
  }

  String _fmtTs(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (booking.isCancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.badBg,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.bad.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.bad, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                booking.statusEnum.displayName,
                style: AppTextStyles.label.copyWith(color: AppColors.bad),
              ),
            ),
          ],
        ),
      );
    }

    final cur = _currentIndex();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _steps.length,
        separatorBuilder: (_, i) => _StepConnector(done: i < cur),
        itemBuilder: (_, i) {
          final done = i < cur;
          final active = i == cur;
          final ts = _tsFor(i);
          final color = active
              ? AppColors.accent
              : done
              ? AppColors.good
              : AppColors.darkFg3;
          return SizedBox(
            width: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_steps[i].$3, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  _steps[i].$2,
                  style: AppTextStyles.caption.copyWith(color: color),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ts != null)
                  Text(
                    _fmtTs(ts),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg3,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool done;
  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 16,
        height: 1.5,
        color: done ? AppColors.good : AppColors.darkLine,
      ),
    );
  }
}

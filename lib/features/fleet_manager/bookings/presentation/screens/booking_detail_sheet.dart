import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/network/result.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../drivers/domain/driver_repo.dart';
import '../../../vehicles/domain/vehicle_repo.dart';
import '../../domain/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';

class BookingDetailSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: openAssign ? 0.85 : 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Text('Booking Details', style: AppTextStyles.h3),
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
                    _Section(
                      title: 'Trip',
                      children: [
                        _Row('Client', booking.corporateClientName ?? '—'),
                        _Row('Employee', booking.employeeName ?? '—'),
                        _Row('Pickup', booking.pickupAddress),
                        _Row('Drop', booking.dropAddress),
                        _Row('Scheduled', _fmt(booking.scheduledAt)),
                        _Row('Type', booking.vehicleTypeRequested ?? '—'),
                        if (booking.notes != null)
                          _Row('Notes', booking.notes!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Status & Fare',
                      children: [
                        _Row('Status', booking.status.replaceAll('_', ' ')),
                        if (booking.estimatedFare != null)
                          _Row(
                            'Est. Fare',
                            '₹${booking.estimatedFare!.toStringAsFixed(2)}',
                          ),
                        if (booking.finalFare != null)
                          _Row(
                            'Final Fare',
                            '₹${booking.finalFare!.toStringAsFixed(2)}',
                          ),
                        if (booking.rejectionReason != null)
                          _Row('Rejection Reason', booking.rejectionReason!),
                        if (booking.cancellationReason != null)
                          _Row(
                            'Cancellation Reason',
                            booking.cancellationReason!,
                          ),
                      ],
                    ),
                    if (booking.driverName != null) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Assignment',
                        children: [
                          _Row('Driver', booking.driverName!),
                          if (booking.vehiclePlate != null)
                            _Row('Vehicle', booking.vehiclePlate!),
                        ],
                      ),
                    ],
                    if (openAssign && booking.isApproved) ...[
                      const SizedBox(height: 20),
                      _AssignDriverPanel(booking: booking),
                    ],
                    if (!openAssign &&
                        (booking.isPending || booking.isApproved)) ...[
                      const SizedBox(height: 20),
                      _ActionButtons(booking: booking),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
  bool _loading = true;
  List<Map<String, String>> _drivers = [];
  List<Map<String, String>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final driverRepo = getIt<DriverRepo>();
    final vehicleRepo = getIt<VehicleRepo>();
    final dr = await driverRepo.list();
    final vr = await vehicleRepo.list(status: 'ACTIVE');
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (dr.isSuccess) {
        _drivers = dr.valueOrNull!
            .where((d) => d.availability == 'AVAILABLE')
            .map((d) => {'id': d.id, 'name': d.fullName, 'phone': d.phone})
            .toList();
      }
      if (vr.isSuccess) {
        _vehicles = vr.valueOrNull!
            .where(
              (v) =>
                  v.status == 'ACTIVE' &&
                  (widget.booking.vehicleTypeRequested == null ||
                      v.vehicleType == widget.booking.vehicleTypeRequested),
            )
            .map(
              (v) => {
                'id': v.id,
                'plate': v.plateNumber,
                'type': v.vehicleType,
              },
            )
            .toList();
      }
    });
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assign Driver & Vehicle', style: AppTextStyles.h4),
        const SizedBox(height: 14),
        Text('Available Drivers', style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (_drivers.isEmpty)
          _emptyChip('No available drivers')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _drivers.map((d) {
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
                    color: selected ? AppColors.primary : AppColors.grey50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.grey200,
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
                          color: selected ? AppColors.white : AppColors.grey800,
                        ),
                      ),
                      Text(
                        d['phone']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.white.withOpacity(0.8)
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        Text('Available Vehicles', style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (_vehicles.isEmpty)
          _emptyChip('No available vehicles')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _vehicles.map((v) {
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
                    color: selected ? AppColors.primary : AppColors.grey50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.grey200,
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
                          color: selected ? AppColors.white : AppColors.grey800,
                        ),
                      ),
                      Text(
                        v['type']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.white.withOpacity(0.8)
                              : AppColors.grey500,
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
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.grey200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _selectedDriverId != null && _selectedVehicleId != null
                  ? 'Assign $_selectedDriverName • $_selectedVehiclePlate'
                  : 'Select driver and vehicle',
              style: TextStyle(
                color: _selectedDriverId != null
                    ? AppColors.white
                    : AppColors.grey400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: AppTextStyles.caption),
  );
}

class _ActionButtons extends StatelessWidget {
  final Booking booking;
  const _ActionButtons({required this.booking});

  @override
  Widget build(BuildContext context) {
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
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),
        ],
      );
    }

    if (booking.isApproved) {
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
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(10),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
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
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

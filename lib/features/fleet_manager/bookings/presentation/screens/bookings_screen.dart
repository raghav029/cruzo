import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_detail_sheet.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String? _filter;

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Pending', value: 'PENDING_APPROVAL'),
    (label: 'Approved', value: 'APPROVED'),
    (label: 'Assigned', value: 'DRIVER_ASSIGNED'),
    (label: 'Active', value: 'IN_PROGRESS'),
    (label: 'Completed', value: 'COMPLETED'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const BookingLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is BookingMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final bookings = switch (state) {
            BookingLoaded(:final bookings) => bookings,
            BookingMutating(:final bookings) => bookings,
            BookingMutationSuccess(:final bookings) => bookings,
            BookingMutationError(:final bookings) => bookings,
            _ => <Booking>[],
          };

          final mutatingId = state is BookingMutating ? state.bookingId : null;
          final pendingCount = bookings.where((b) => b.isPending).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Bookings', style: AppTextStyles.h2),
                              if (pendingCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('$pendingCount pending',
                                      style: const TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w700,
                                          color: AppColors.warning)),
                                ),
                              ],
                            ],
                          ),
                          Text('${bookings.length} total', style: AppTextStyles.bodySm),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.read<BookingBloc>()
                            .add(BookingLoadRequested(statusFilter: _filter)),
                        icon: const Icon(Icons.refresh_outlined, color: AppColors.grey600),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final selected = _filter == f.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f.label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _filter = f.value);
                              context.read<BookingBloc>()
                                  .add(BookingLoadRequested(statusFilter: f.value));
                            },
                            selectedColor: AppColors.primaryLight,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primary : AppColors.grey600,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                                color: selected ? AppColors.primary : AppColors.grey200),
                            backgroundColor: AppColors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              if (state is BookingLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state is BookingError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: AppTextStyles.body, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<BookingBloc>()
                              .add(const BookingLoadRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (bookings.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.grey300),
                        const SizedBox(height: 12),
                        Text('No bookings', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text('Bookings will appear here once employees create them.',
                            style: AppTextStyles.bodySm, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _BookingCard(
                      booking: bookings[i],
                      isMutating: mutatingId == bookings[i].id,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isMutating;

  const _BookingCard({required this.booking, required this.isMutating});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BookingDetailSheet.show(context, booking: booking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: booking.isPending ? AppColors.warning.withOpacity(0.4) : AppColors.grey200,
            width: booking.isPending ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.corporateClientName ?? 'Unknown Client',
                        style: AppTextStyles.h4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.employeeName ?? 'Unknown Employee',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: booking.status),
                if (isMutating) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _RouteRow(pickup: booking.pickupAddress, drop: booking.dropAddress),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 13, color: AppColors.grey400),
                const SizedBox(width: 4),
                Text(_formatDate(booking.scheduledAt), style: AppTextStyles.caption),
                if (booking.vehicleTypeRequested != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.directions_car_outlined, size: 13, color: AppColors.grey400),
                  const SizedBox(width: 4),
                  Text(booking.vehicleTypeRequested!, style: AppTextStyles.caption),
                ],
                if (booking.estimatedFare != null) ...[
                  const Spacer(),
                  Text('₹${booking.estimatedFare!.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey700)),
                ],
              ],
            ),
            if (booking.driverName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 13, color: AppColors.grey400),
                  const SizedBox(width: 4),
                  Text('${booking.driverName} • ${booking.vehiclePlate ?? ''}',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
            if (booking.isPending || booking.isApproved) ...[
              const SizedBox(height: 12),
              _QuickActions(booking: booking, isMutating: isMutating),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, $h:$m';
    } catch (_) {
      return iso;
    }
  }
}

class _QuickActions extends StatelessWidget {
  final Booking booking;
  final bool isMutating;

  const _QuickActions({required this.booking, required this.isMutating});

  @override
  Widget build(BuildContext context) {
    if (booking.isPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isMutating ? null : () => _confirmReject(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: isMutating
                  ? null
                  : () => context.read<BookingBloc>().add(BookingApproveRequested(booking.id)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 13, color: AppColors.white)),
            ),
          ),
        ],
      );
    }

    if (booking.isApproved) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isMutating
                  ? null
                  : () => context.read<BookingBloc>().add(BookingAutoAssignRequested(booking.id)),
              icon: const Icon(Icons.auto_awesome_outlined, size: 15),
              label: const Text('Auto-assign', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: isMutating
                  ? null
                  : () => BookingDetailSheet.show(context, booking: booking, openAssign: true),
              icon: const Icon(Icons.person_pin_outlined, size: 15),
              label: const Text('Assign', style: TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _confirmReject(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Optionally provide a rejection reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<BookingBloc>().add(
                  BookingRejectRequested(booking.id,
                      reason: reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim()));
            },
            child: const Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String pickup;
  final String drop;

  const _RouteRow({required this.pickup, required this.drop});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            ),
            Container(width: 1, height: 20, color: AppColors.grey200),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup,
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              const SizedBox(height: 12),
              Text(drop,
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      'PENDING_APPROVAL' => (AppColors.warning, AppColors.warningLight, 'Pending'),
      'APPROVED' => (AppColors.info, AppColors.infoLight, 'Approved'),
      'DRIVER_ASSIGNED' => (AppColors.primary, AppColors.primaryLight, 'Assigned'),
      'DRIVER_EN_ROUTE' => (AppColors.primary, AppColors.primaryLight, 'En Route'),
      'ARRIVED' => (AppColors.primary, AppColors.primaryLight, 'Arrived'),
      'IN_PROGRESS' => (AppColors.success, AppColors.successLight, 'In Progress'),
      'COMPLETED' => (AppColors.success, AppColors.successLight, 'Completed'),
      'REJECTED' => (AppColors.error, AppColors.errorLight, 'Rejected'),
      _ when status.startsWith('CANCELLED') => (AppColors.grey500, AppColors.grey100, 'Cancelled'),
      _ => (AppColors.grey500, AppColors.grey100, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

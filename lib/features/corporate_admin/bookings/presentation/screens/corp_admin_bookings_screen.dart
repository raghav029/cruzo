import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_bloc.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_event.dart';
import '../../../../fleet_manager/bookings/presentation/bloc/booking_state.dart';
import '../../../../fleet_manager/bookings/presentation/screens/booking_detail_sheet.dart';

class CorpAdminBookingsScreen extends StatefulWidget {
  const CorpAdminBookingsScreen({super.key});

  @override
  State<CorpAdminBookingsScreen> createState() =>
      _CorpAdminBookingsScreenState();
}

class _CorpAdminBookingsScreenState extends State<CorpAdminBookingsScreen> {
  BookingStatus? _filter;

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Pending', value: BookingStatus.pendingApproval),
    (label: 'Approved', value: BookingStatus.approved),
    (label: 'Active', value: BookingStatus.inProgress),
    (label: 'Completed', value: BookingStatus.completed),
    (label: 'Cancelled', value: BookingStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const BookingLoadRequested());
  }

  void _applyFilter(BookingStatus? status) {
    setState(() => _filter = status);
    context
        .read<BookingBloc>()
        .add(BookingLoadRequested(statusFilter: status?.rawValue));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.good,
              ),
            );
            _applyFilter(_filter);
          } else if (state is BookingMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.bad,
              ),
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

          final mutatingId =
              state is BookingMutating ? state.bookingId : null;
          final pendingCount = bookings.where((b) => b.isPending).length;
          final isLoading = state is BookingLoading;

          return CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warnBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$pendingCount pending',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warn,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${bookings.length} total',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.darkFg2),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _applyFilter(_filter),
                        icon: const Icon(Icons.refresh_outlined,
                            color: AppColors.darkFg2),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter chips ─────────────────────────────────────────────
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
                            onSelected: (_) => _applyFilter(f.value),
                            selectedColor: AppColors.accentBg,
                            checkmarkColor: AppColors.accent,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.darkFg2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is BookingError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.bad),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.body),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _applyFilter(_filter),
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
                        Icon(Icons.book_online_outlined,
                            size: 56, color: AppColors.darkBg3),
                        const SizedBox(height: 12),
                        Text('No bookings found', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text(
                          _filter == null
                              ? 'Your employees have not made any bookings yet'
                              : 'No bookings with this status',
                          style: AppTextStyles.bodySm,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isMutating;

  const _BookingCard({required this.booking, required this.isMutating});

  String _fmt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BookingDetailSheet.show(context, booking: booking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: booking.isPending
                ? AppColors.warn.withOpacity(0.3)
                : AppColors.darkLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: employee + status ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.employeeName ?? 'Unknown Employee',
                        style: AppTextStyles.h4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.vehicleTypeRequested != null)
                        Text(
                          booking.vehicleTypeRequested!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: booking.statusEnum),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.darkLine),
            const SizedBox(height: 10),

            // ── Route ───────────────────────────────────────────────────
            _RouteRow(
              icon: Icons.radio_button_checked,
              iconColor: AppColors.good,
              text: booking.pickupAddress,
            ),
            const SizedBox(height: 6),
            _RouteRow(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.bad,
              text: booking.dropAddress,
            ),

            const SizedBox(height: 10),

            // ── Meta row ────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: AppColors.darkFg3),
                const SizedBox(width: 4),
                Text(_fmt(booking.scheduledAt), style: AppTextStyles.caption),
                if (booking.estimatedFare != null) ...[
                  const Spacer(),
                  Text(
                    '₹${booking.estimatedFare!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkFg1,
                    ),
                  ),
                ],
              ],
            ),

            if (booking.driverName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppColors.darkFg3),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.driverName}'
                    '${booking.vehiclePlate != null ? ' · ${booking.vehiclePlate}' : ''}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],

            // ── Quick actions (pending only) ─────────────────────────────
            if (booking.isPending) ...[
              const SizedBox(height: 12),
              _PendingActions(booking: booking, isMutating: isMutating),
            ],

            // ── Cancel (approved / assigned) ────────────────────────────
            if (booking.isApproved ||
                booking.statusEnum == BookingStatus.driverAssigned) ...[
              const SizedBox(height: 12),
              _CancelAction(booking: booking, isMutating: isMutating),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Route row ─────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _RouteRow(
      {required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// ── Pending actions ───────────────────────────────────────────────────────────

class _PendingActions extends StatelessWidget {
  final Booking booking;
  final bool isMutating;

  const _PendingActions({required this.booking, required this.isMutating});

  void _confirmReject(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provide a reason for rejection:',
                style: AppTextStyles.body),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Outside service hours',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
            onPressed: () {
              context.read<BookingBloc>().add(
                    BookingRejectRequested(
                      booking.id,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? null
                          : reasonCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isMutating ? null : () => _confirmReject(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.bad,
              side: const BorderSide(color: AppColors.bad),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: isMutating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reject', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: isMutating
                ? null
                : () => context
                    .read<BookingBloc>()
                    .add(BookingApproveRequested(booking.id)),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.good,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: isMutating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Approve',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.accentFg)),
          ),
        ),
      ],
    );
  }
}

// ── Cancel action ─────────────────────────────────────────────────────────────

class _CancelAction extends StatelessWidget {
  final Booking booking;
  final bool isMutating;

  const _CancelAction({required this.booking, required this.isMutating});

  void _confirmCancel(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provide a cancellation reason:',
                style: AppTextStyles.body),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Employee unavailable',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bad),
            onPressed: () {
              context.read<BookingBloc>().add(
                    BookingCancelRequested(
                      booking.id,
                      reason: reasonCtrl.text.trim().isEmpty
                          ? null
                          : reasonCtrl.text.trim(),
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isMutating ? null : () => _confirmCancel(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkFg2,
          side: const BorderSide(color: AppColors.darkLine),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        child: const Text('Cancel booking', style: TextStyle(fontSize: 13)),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      BookingStatus.pendingApproval => (
        AppColors.warn,
        AppColors.warnBg,
        'Pending',
      ),
      BookingStatus.approved => (
        AppColors.info,
        AppColors.infoBg,
        'Approved',
      ),
      BookingStatus.driverAssigned => (
        AppColors.accent,
        AppColors.accentBg,
        'Assigned',
      ),
      BookingStatus.driverEnRoute => (
        AppColors.accent,
        AppColors.accentBg,
        'En Route',
      ),
      BookingStatus.arrived => (
        AppColors.accent,
        AppColors.accentBg,
        'Arrived',
      ),
      BookingStatus.inProgress => (
        AppColors.good,
        AppColors.goodBg,
        'In Progress',
      ),
      BookingStatus.completed => (
        AppColors.good,
        AppColors.goodBg,
        'Completed',
      ),
      BookingStatus.rejected => (AppColors.bad, AppColors.badBg, 'Rejected'),
      BookingStatus.cancelled ||
      BookingStatus.cancelledByDriver ||
      BookingStatus.cancelledByEmployee ||
      BookingStatus.cancelledByAdmin ||
      BookingStatus.cancelledByFleetManager => (
        AppColors.darkFg3,
        AppColors.darkBg3,
        'Cancelled',
      ),
      _ => (AppColors.darkFg3, AppColors.darkBg3, status.displayName),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

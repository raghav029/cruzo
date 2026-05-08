import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../core/di/injection.dart';
import '../../../bookings/domain/booking_repo.dart';
import '../../../bookings/domain/booking.dart';
import '../../../bookings/presentation/screens/booking_detail_sheet.dart';
import '../../../bookings/presentation/bloc/booking_bloc.dart';

class DailyTripsScreen extends StatefulWidget {
  const DailyTripsScreen({super.key});

  @override
  State<DailyTripsScreen> createState() => _DailyTripsScreenState();
}

class _DailyTripsScreenState extends State<DailyTripsScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  String? _error;
  List<Booking> _bookings = [];

  static const _activeStatuses = [
    'DRIVER_ASSIGNED',
    'DRIVER_EN_ROUTE',
    'ARRIVED',
    'IN_PROGRESS',
    'COMPLETED',
    'APPROVED',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _dateParam(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${y}-${mo}-${day}T00:00:00Z';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = getIt<BookingRepo>();
    final from = _dateParam(_selectedDate);
    final to = _dateParam(_selectedDate.add(const Duration(days: 1)));
    final result = await repo.list(fromDate: from, toDate: to, size: 100);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        setState(() {
          _loading = false;
          _bookings =
              value.where((b) => _activeStatuses.contains(b.status)).toList()
                ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        });
      case Failure(:final message):
        setState(() {
          _loading = false;
          _error = message;
        });
    }
  }

  void _prevDay() {
    setState(
      () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
    );
    _load();
  }

  void _nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.isBefore(tomorrow)) {
      setState(
        () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
      );
      _load();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _headerLabel() {
    if (_isToday) return 'Today';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (_selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day)
      return 'Yesterday';
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
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Map<String, List<Booking>> get _grouped {
    final order = [
      'IN_PROGRESS',
      'DRIVER_EN_ROUTE',
      'ARRIVED',
      'DRIVER_ASSIGNED',
      'APPROVED',
      'COMPLETED',
    ];
    final map = <String, List<Booking>>{};
    for (final b in _bookings) {
      map.putIfAbsent(b.status, () => []).add(b);
    }
    final sorted = <String, List<Booking>>{};
    for (final s in order) {
      if (map.containsKey(s)) sorted[s] = map[s]!;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingBloc>(),
      child: BlocListener<BookingBloc, dynamic>(
        listener: (context, state) => _load(),
        child: Scaffold(
          backgroundColor: AppColors.darkBg1,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  label: _headerLabel(),
                  isToday: _isToday,
                  onPrev: _prevDay,
                  onNext: _nextDay,
                  onTap: _pickDate,
                  tripCount: _bookings.length,
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: _ErrorView(message: _error!, onRetry: _load),
                )
              else if (_bookings.isEmpty)
                SliverFillRemaining(child: _EmptyView(isToday: _isToday))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final groups = _grouped.entries.toList();
                        int idx = 0;
                        for (final entry in groups) {
                          if (i == idx) {
                            return _GroupHeader(
                              status: entry.key,
                              count: entry.value.length,
                            );
                          }
                          idx++;
                          for (final booking in entry.value) {
                            if (i == idx) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TripCard(
                                  booking: booking,
                                  onTap: () {
                                    BookingDetailSheet.show(
                                      context,
                                      booking: booking,
                                    );
                                  },
                                ),
                              );
                            }
                            idx++;
                          }
                        }
                        return null;
                      },
                      childCount: _grouped.entries.fold(
                        0,
                        (sum, e) => sum! + 1 + e.value.length,
                      ),
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

class _Header extends StatelessWidget {
  final String label;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTap;
  final int tripCount;

  const _Header({
    required this.label,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onTap,
    required this.tripCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Trips',
                    style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0),
                  ),
                  Text(
                    '$tripCount active trips',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.darkFg2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.darkFg2),
                onPressed: onPrev,
                padding: EdgeInsets.zero,
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.accentBg : AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isToday ? AppColors.accent : AppColors.darkLine,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: isToday ? AppColors.accent : AppColors.darkFg2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.h4.copyWith(
                          color: isToday ? AppColors.accent : AppColors.darkFg1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.darkFg2),
                onPressed: onNext,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String status;
  final int count;
  const _GroupHeader({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'IN_PROGRESS' => ('In Progress', AppColors.good),
      'DRIVER_EN_ROUTE' => ('En Route', AppColors.accent),
      'ARRIVED' => ('Arrived', AppColors.accent),
      'DRIVER_ASSIGNED' => ('Assigned', AppColors.info),
      'APPROVED' => ('Approved — Awaiting Dispatch', AppColors.warn),
      'COMPLETED' => ('Completed', AppColors.darkFg2),
      _ => (status, AppColors.darkFg2),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: AppTextStyles.bodySm.copyWith(color: color.withAlpha(128)),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  const _TripCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLive =
        booking.status == 'IN_PROGRESS' ||
        booking.status == 'DRIVER_EN_ROUTE' ||
        booking.status == 'ARRIVED';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isLive ? AppColors.good.withAlpha(80) : AppColors.darkLine,
            width: isLive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TimeChip(scheduledAt: booking.scheduledAt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.corporateClientName ?? 'Unknown Client',
                    style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.good,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _RouteRow(pickup: booking.pickupAddress, drop: booking.dropAddress),
            if (booking.driverName != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.darkLine),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.darkFg3,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.driverName!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg2,
                    ),
                  ),
                  if (booking.vehiclePlate != null) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 14,
                      color: AppColors.darkFg3,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.vehiclePlate!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg2,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (booking.employeeName != null)
                    Text(
                      booking.employeeName!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg2,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String scheduledAt;
  const _TimeChip({required this.scheduledAt});

  @override
  Widget build(BuildContext context) {
    String label;
    try {
      final dt = DateTime.parse(scheduledAt).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      label = '$h:$m';
    } catch (_) {
      label = '--:--';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkFg1,
        ),
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
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.good,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 18, color: AppColors.darkLine),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.bad,
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
              Text(
                pickup,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Text(
                drop,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isToday;
  const _EmptyView({required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 56,
            color: AppColors.darkFg3,
          ),
          const SizedBox(height: 12),
          Text(
            'No trips ${isToday ? 'today' : 'on this day'}',
            style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
          ),
          const SizedBox(height: 4),
          Text(
            'Active trips will appear here once assigned.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.bad),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

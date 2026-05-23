import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../shared/widgets/booking_map_card.dart';
import '../../../bookings/domain/booking_status.dart';
import '../../../bookings/domain/booking.dart';
import '../../../bookings/presentation/bloc/booking_bloc.dart';
import '../../../bookings/presentation/screens/booking_detail_sheet.dart';
import '../view_models/daily_trips_view_model.dart';

class DailyTripsScreen extends StatefulWidget {
  const DailyTripsScreen({super.key});

  @override
  State<DailyTripsScreen> createState() => _DailyTripsScreenState();
}

class _DailyTripsScreenState extends State<DailyTripsScreen> {
  DateTime _selectedDate = DateTime.now();
  Booking? _selected;
  String _filter = 'all';
  late final DailyTripsViewModel _vm;

  static const _activeStatuses = [
    BookingStatus.approved,
    BookingStatus.driverAssigned,
    BookingStatus.driverEnRoute,
    BookingStatus.arrived,
    BookingStatus.inProgress,
    BookingStatus.completed,
  ];

  bool get _loading => _vm.isLoading;
  String? get _error => _vm.error;
  List<Booking> get _bookings => _vm.bookings
      .where((b) => _activeStatuses.contains(b.statusEnum))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  @override
  void initState() {
    super.initState();
    _vm = getIt<DailyTripsViewModel>();
    _load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _vm.load(_selectedDate);
    if (!mounted) return;
    setState(() {
      final filtered = _bookings;
      if (_selected != null) {
        _selected = filtered.firstWhere(
          (b) => b.id == _selected!.id,
          orElse: () => filtered.isNotEmpty ? filtered.first : _selected!,
        );
      } else if (filtered.isNotEmpty) {
        _selected = filtered.first;
      }
    });
  }

  List<Booking> get _visible {
    return switch (_filter) {
      'unassigned' => _bookings.where((b) => b.statusEnum.needsDriver).toList(),
      'assigned' =>
        _bookings
            .where((b) => b.statusEnum == BookingStatus.driverAssigned)
            .toList(),
      'live' => _bookings.where((b) => b.statusEnum.isActive).toList(),
      'done' => _bookings.where((b) => b.statusEnum.isCompleted).toList(),
      _ => _bookings,
    };
  }

  bool get _isToday {
    final n = DateTime.now();
    return _selectedDate.year == n.year &&
        _selectedDate.month == n.month &&
        _selectedDate.day == n.day;
  }

  String _dayLabel() {
    if (_isToday) return 'Today';
    final y = DateTime.now().subtract(const Duration(days: 1));
    if (_selectedDate.year == y.year &&
        _selectedDate.month == y.month &&
        _selectedDate.day == y.day) {
      return 'Yesterday';
    }
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
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => BlocProvider(
        create: (_) => getIt<BookingBloc>(),
        child: BlocListener<BookingBloc, dynamic>(
          listener: (_, _) => _load(),
          child: Scaffold(
            backgroundColor: AppColors.darkBg1,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 780;
              if (wide) return _WideLayout(screen: this);
              return _NarrowLayout(screen: this);
            },
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Wide layout (tablet / web) ───────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final _DailyTripsScreenState screen;
  const _WideLayout({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 340,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.darkLine)),
            ),
            child: Column(
              children: [
                _ListHeader(screen: screen),
                Expanded(child: _TripList(screen: screen, wide: true)),
              ],
            ),
          ),
        ),
        Expanded(
          child: screen._selected == null
              ? _EmptyDetail()
              : _DetailPanel(
                  booking: screen._selected!,
                  onRefresh: screen._load,
                ),
        ),
      ],
    );
  }
}

// ─── Narrow layout (mobile) ───────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final _DailyTripsScreenState screen;
  const _NarrowLayout({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ListHeader(screen: screen),
        Expanded(child: _TripList(screen: screen, wide: false)),
      ],
    );
  }
}

// ─── Shared list header ───────────────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  final _DailyTripsScreenState screen;
  const _ListHeader({required this.screen});

  @override
  Widget build(BuildContext context) {
    final s = screen;
    final needDriver = s._bookings
        .where((b) => b.statusEnum.needsDriver)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        s._dayLabel(),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.darkFg0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.darkFg3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: s._selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 90),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (picked != null) {
                            // ignore: invalid_use_of_protected_member
                            s.setState(() => s._selectedDate = picked);
                            s._load();
                          }
                        },
                        child: Text(
                          _fullDate(s._selectedDate),
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${s._bookings.length} trips${needDriver > 0 ? ' · $needDriver need driver' : ''}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.chevron_left,
                    onTap: () {
                      // ignore: invalid_use_of_protected_member
                      s.setState(
                        () => s._selectedDate = s._selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      );
                      s._load();
                    },
                  ),
                  _IconBtn(
                    icon: Icons.chevron_right,
                    onTap: () {
                      // ignore: invalid_use_of_protected_member
                      s.setState(
                        () => s._selectedDate = s._selectedDate.add(
                          const Duration(days: 1),
                        ),
                      );
                      s._load();
                    },
                  ),
                  _IconBtn(icon: Icons.refresh_outlined, onTap: s._load),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _FilterBar(screen: screen),
        const Divider(height: 1, color: AppColors.darkLine),
      ],
    );
  }

  String _fullDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      child: Icon(icon, size: 18, color: AppColors.darkFg2),
    ),
  );
}

class _FilterBar extends StatelessWidget {
  final _DailyTripsScreenState screen;
  const _FilterBar({required this.screen});

  static const _chips = [
    ('all', 'All'),
    ('unassigned', 'Unassigned'),
    ('assigned', 'Assigned'),
    ('live', 'Live'),
    ('done', 'Done'),
  ];

  int _count(_DailyTripsScreenState s, String f) => switch (f) {
    'unassigned' => s._bookings.where((b) => b.statusEnum.needsDriver).length,
    'assigned' =>
      s._bookings
          .where((b) => b.statusEnum == BookingStatus.driverAssigned)
          .length,
    'live' => s._bookings.where((b) => b.statusEnum.isActive).length,
    'done' => s._bookings.where((b) => b.statusEnum.isCompleted).length,
    _ => s._bookings.length,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: _chips.map((chip) {
          final (key, label) = chip;
          final active = screen._filter == key;
          final count = _count(screen, key);
          return GestureDetector(
            // ignore: invalid_use_of_protected_member
            onTap: () => screen.setState(() => screen._filter = key),
            child: Container(
              margin: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent.withAlpha(20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.darkLine,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: active ? AppColors.accent : AppColors.darkFg2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Trip list ────────────────────────────────────────────────────────────────

class _TripList extends StatelessWidget {
  final _DailyTripsScreenState screen;
  final bool wide;
  const _TripList({required this.screen, required this.wide});

  @override
  Widget build(BuildContext context) {
    if (screen._loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (screen._error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.bad, size: 40),
            const SizedBox(height: 8),
            Text(
              screen._error!,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg1),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: screen._load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final visible = screen._visible;
    if (visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppColors.darkFg3,
            ),
            const SizedBox(height: 10),
            Text(
              'No trips',
              style: AppTextStyles.h4.copyWith(color: AppColors.darkFg1),
            ),
            Text(
              'Nothing matches this filter.',
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final b = visible[i];
        final isSelected = wide && screen._selected?.id == b.id;
        return _TripCard(
          booking: b,
          selected: isSelected,
          onTap: () {
            if (wide) {
              // ignore: invalid_use_of_protected_member
              screen.setState(() => screen._selected = b);
            } else {
              showModalBottomSheet(
                context: ctx,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: ctx.read<BookingBloc>(),
                  child: BookingDetailSheet(booking: b),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final Booking booking;
  final bool selected;
  final VoidCallback onTap;
  const _TripCard({
    required this.booking,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = booking.isActive;
    final needsDriver = booking.statusEnum.needsDriver;

    Color borderColor = AppColors.darkLine;
    if (selected) {
      borderColor = AppColors.accent;
    } else if (isLive) {
      borderColor = AppColors.good.withAlpha(100);
    } else if (needsDriver) {
      borderColor = AppColors.warn.withAlpha(100);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withAlpha(12) : AppColors.darkBg2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _timeChip(booking.scheduledAt),
                const SizedBox(width: 8),
                if (isLive) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.good,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    booking.corporateClientName ?? '—',
                    style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusDot(status: booking.statusEnum),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              booking.employeeName ?? '—',
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg2),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${_short(booking.pickupAddress)}  →  ${_short(booking.dropAddress)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (booking.driverName != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.darkLine),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
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
                    const SizedBox(width: 10),
                    Text(
                      '·',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.vehiclePlate!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ] else if (needsDriver) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warn.withAlpha(16),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.warn.withAlpha(60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      size: 13,
                      color: AppColors.warn,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'No driver assigned',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeChip(String iso) {
    String label = '--:--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      label =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(AppRadii.xs),
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

  String _short(String addr) {
    final parts = addr.split(',');
    return parts.first.trim();
  }
}

class _StatusDot extends StatelessWidget {
  final BookingStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final label = switch (status) {
      BookingStatus.inProgress => 'Live',
      BookingStatus.driverEnRoute => 'En Route',
      BookingStatus.arrived => 'Arrived',
      BookingStatus.driverAssigned => 'Assigned',
      BookingStatus.approved => 'Pending',
      BookingStatus.completed => 'Done',
      _ => status.displayName,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}

// ─── Right panel: trip detail ─────────────────────────────────────────────────

class _EmptyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 48,
            color: AppColors.darkFg3,
          ),
          const SizedBox(height: 10),
          Text(
            'Select a trip',
            style: AppTextStyles.h4.copyWith(color: AppColors.darkFg1),
          ),
          Text(
            'Click any trip on the left to see details.',
            style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatefulWidget {
  final Booking booking;
  final VoidCallback onRefresh;
  const _DetailPanel({required this.booking, required this.onRefresh});

  @override
  State<_DetailPanel> createState() => _DetailPanelState();
}

class _DetailPanelState extends State<_DetailPanel> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPollingIfLive();
  }

  void _startPollingIfLive() {
    _pollTimer?.cancel();
    if (widget.booking.statusEnum == BookingStatus.inProgress) {
      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        widget.onRefresh();
      });
    }
  }

  @override
  void didUpdateWidget(_DetailPanel old) {
    super.didUpdateWidget(old);
    if (old.booking.id != widget.booking.id ||
        old.booking.statusEnum != widget.booking.statusEnum) {
      _startPollingIfLive();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.corporateClientName ?? 'Trip Detail',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.darkFg0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 13,
                          color: AppColors.darkFg3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fmtTime(b.scheduledAt),
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.darkFg2,
                          ),
                        ),
                        if (b.vehicleTypeRequested != null) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 13,
                            color: AppColors.darkFg3,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            b.vehicleTypeRequested!.toLowerCase(),
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.darkFg2,
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        _StatusDot(status: b.statusEnum),
                      ],
                    ),
                  ],
                ),
              ),
              if (b.isApproved)
                FilledButton.icon(
                  onPressed: () => BookingDetailSheet.show(
                    context,
                    booking: b,
                    openAssign: true,
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 15),
                  label: const Text('Assign driver'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.darkBg1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Map (if coords available)
          if (b.hasCoords || b.hasDriverLocation) ...[
            BookingMapCard(booking: b),
            const SizedBox(height: AppSpacing.md),
          ],

          // Driver + Booking info cards row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DriverCard(booking: b, onAssign: widget.onRefresh),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _TripInfoCard(booking: b)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Route card
          _RouteCard(booking: b),
          const SizedBox(height: AppSpacing.md),

          // Status timeline
          _TimelineCard(booking: b),
        ],
      ),
    );
  }

  String _fmtTime(String iso) {
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
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, $h:$m IST';
    } catch (_) {
      return iso;
    }
  }
}

class _DriverCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onAssign;
  const _DriverCard({required this.booking, required this.onAssign});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Driver & Vehicle',
            style: AppTextStyles.tableHeader.copyWith(
              color: AppColors.darkFg3,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (booking.driverName != null) ...[
            Row(
              children: [
                _Avatar(name: booking.driverName!),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.driverName!,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.darkFg0,
                        ),
                      ),
                      if (booking.vehiclePlate != null)
                        Text(
                          booking.vehiclePlate!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.darkFg3,
                            fontFamily: 'monospace',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            Column(
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  size: 28,
                  color: AppColors.warn,
                ),
                const SizedBox(height: 6),
                Text(
                  'No driver assigned',
                  style: AppTextStyles.label.copyWith(color: AppColors.darkFg1),
                ),
                const SizedBox(height: 4),
                Text(
                  'Assign before pickup to avoid 7am alert.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => BookingDetailSheet.show(
                      context,
                      booking: booking,
                      openAssign: true,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    child: const Text('Assign driver'),
                  ),
                ),
              ],
            ),
          ],
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
          Text(
            'Trip info',
            style: AppTextStyles.tableHeader.copyWith(
              color: AppColors.darkFg3,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Employee', value: booking.employeeName ?? '—'),
          _InfoRow(label: 'Status', value: booking.statusEnum.displayName),
          if (booking.estimatedFare != null)
            _InfoRow(
              label: 'Est. Fare',
              value: '₹${booking.estimatedFare!.toStringAsFixed(0)}',
            ),
          if (booking.finalFare != null)
            _InfoRow(
              label: 'Final Fare',
              value: '₹${booking.finalFare!.toStringAsFixed(0)}',
            ),
          if (booking.notes != null)
            _InfoRow(label: 'Notes', value: booking.notes!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final Booking booking;
  const _RouteCard({required this.booking});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Route',
            style: AppTextStyles.tableHeader.copyWith(
              color: AppColors.darkFg3,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.good,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(width: 1, height: 24, color: AppColors.darkLine),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.bad,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.pickupAddress,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.darkFg1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      booking.dropAddress,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.darkFg1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Booking booking;
  const _TimelineCard({required this.booking});

  static const _steps = [
    (BookingStatus.pendingApproval, 'Pending', Icons.pending_outlined),
    (BookingStatus.approved, 'Approved', Icons.check_circle_outline),
    (BookingStatus.driverAssigned, 'Assigned', Icons.person_pin_outlined),
    (BookingStatus.driverEnRoute, 'En Route', Icons.directions_car_outlined),
    (BookingStatus.arrived, 'Arrived', Icons.location_on_outlined),
    (BookingStatus.inProgress, 'Trip', Icons.play_circle_outline),
    (BookingStatus.completed, 'Done', Icons.flag_outlined),
  ];

  int _cur() {
    for (var i = 0; i < _steps.length; i++) {
      if (_steps[i].$1 == booking.statusEnum) return i;
    }
    return 0;
  }

  String? _ts(int i) => switch (i) {
    1 => booking.approvedAt,
    2 => booking.driverAssignedAt,
    5 => booking.tripStartedAt,
    6 => booking.tripCompletedAt,
    _ => null,
  };

  String _fmtTs(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
            Text(
              booking.statusEnum.displayName,
              style: AppTextStyles.label.copyWith(color: AppColors.bad),
            ),
          ],
        ),
      );
    }

    final cur = _cur();
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
          Text(
            'Status timeline',
            style: AppTextStyles.tableHeader.copyWith(
              color: AppColors.darkFg3,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _steps.length,
              separatorBuilder: (_, i) => Center(
                child: Container(
                  width: 16,
                  height: 1.5,
                  color: i < cur ? AppColors.good : AppColors.darkLine,
                ),
              ),
              itemBuilder: (_, i) {
                final done = i < cur;
                final active = i == cur;
                final ts = _ts(i);
                final color = active
                    ? AppColors.accent
                    : done
                    ? AppColors.good
                    : AppColors.darkFg3;
                return SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_steps[i].$3, color: color, size: 17),
                      const SizedBox(height: 3),
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
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.label.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

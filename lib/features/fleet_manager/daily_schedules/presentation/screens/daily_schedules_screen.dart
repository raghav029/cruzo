import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/network/result.dart';
import '../../../bookings/domain/booking_status.dart';
import '../../../drivers/domain/driver.dart';
import '../../../drivers/domain/driver_repo.dart';
import '../../../vehicles/domain/vehicle.dart';
import '../../../vehicles/domain/vehicle_repo.dart';
import '../../domain/daily_schedule_models.dart';
import '../bloc/daily_schedule_bloc.dart';
import '../bloc/daily_schedule_event.dart';
import '../bloc/daily_schedule_state.dart';

class DailySchedulesScreen extends StatefulWidget {
  const DailySchedulesScreen({super.key});

  @override
  State<DailySchedulesScreen> createState() => _DailySchedulesScreenState();
}

class _DailySchedulesScreenState extends State<DailySchedulesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime _tripDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    context.read<DailyScheduleBloc>().add(const ScheduleListRequested());
    _loadTrips();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _dateFmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$mo-$day';
  }

  void _loadTrips() => context.read<DailyScheduleBloc>().add(
    TripsRequested(_dateFmt(_tripDate)),
  );

  void _prevDay() {
    setState(() => _tripDate = _tripDate.subtract(const Duration(days: 1)));
    _loadTrips();
  }

  void _nextDay() {
    setState(() => _tripDate = _tripDate.add(const Duration(days: 1)));
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadH,
                AppSpacing.pagePadV,
                AppSpacing.pagePadH,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Schedules', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.p4),
                  Text(
                    'Recurring cab routes and trip assignments',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TabBar(controller: _tabs),
                ],
              ),
            ),
          ),
        ],
        body: BlocConsumer<DailyScheduleBloc, DailyScheduleState>(
          listener: (context, state) {
            if (state is DailyScheduleMutationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.good,
                ),
              );
              if (_tabs.index == 1) _loadTrips();
            }
            if (state is DailyScheduleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.bad,
                ),
              );
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabs,
              children: [
                _SchedulesTab(state: state),
                _TripsTab(
                  state: state,
                  date: _tripDate,
                  onPrev: _prevDay,
                  onNext: _nextDay,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.darkBg3,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
        unselectedLabelStyle: AppTextStyles.label,
        unselectedLabelColor: AppColors.darkFg2,
        tabs: const [
          Tab(text: 'Schedules'),
          Tab(text: 'Trips'),
        ],
      ),
    );
  }
}

// ── Schedules tab ─────────────────────────────────────────────────────────────

class _SchedulesTab extends StatelessWidget {
  final DailyScheduleState state;
  const _SchedulesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is DailyScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is DailyScheduleError) {
      return _ErrorView(
        message: (state as DailyScheduleError).message,
        onRetry: () => context.read<DailyScheduleBloc>().add(
          const ScheduleListRequested(),
        ),
      );
    }
    if (state is ScheduleListLoaded) {
      final schedules = (state as ScheduleListLoaded).schedules;
      if (schedules.isEmpty) {
        return const _EmptyView(
          icon: Icons.route_outlined,
          message: 'No schedules yet',
          sub: 'Corporate admins create schedules. They will appear here.',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.pagePadH),
        itemCount: schedules.length,
        separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) => _ScheduleCard(
          schedule: schedules[i],
          onManageSequence: () => _showPassengerSheet(context, schedules[i]),
        ),
      );
    }
    return const SizedBox();
  }

  void _showPassengerSheet(BuildContext ctx, DailySchedule schedule) {
    ctx.read<DailyScheduleBloc>().add(PassengersRequested(schedule.id));
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<DailyScheduleBloc>(),
        child: _PassengerSequenceSheet(schedule: schedule),
      ),
    );
  }
}

// ── Schedule card ─────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final DailySchedule schedule;
  final VoidCallback onManageSequence;
  const _ScheduleCard({required this.schedule, required this.onManageSequence});

  @override
  Widget build(BuildContext context) {
    final days = schedule.recurrenceDays
        .map((d) => d.substring(0, 3))
        .join(' · ');

    return GestureDetector(
      onTap: onManageSequence,
      child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(schedule.name, style: AppTextStyles.h4),
                      const SizedBox(height: AppSpacing.p4),
                      Text(
                        schedule.corporateClientName,
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                _TypeBadge(
                  label: schedule.isPooled ? 'Pooled' : 'Individual',
                  color: schedule.isPooled ? AppColors.info : AppColors.accent,
                  bg: schedule.isPooled ? AppColors.infoBg : AppColors.accentBg,
                ),
                const SizedBox(width: AppSpacing.sm),
                if (!schedule.isActive)
                  _TypeBadge(
                    label: 'Inactive',
                    color: AppColors.darkFg3,
                    bg: AppColors.darkBg3,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.p12),
            const Divider(height: 1, color: AppColors.darkLine),
            const SizedBox(height: AppSpacing.p12),
            Row(
              children: [
                _MetaItem(
                  icon: Icons.access_time_rounded,
                  label: schedule.pickupTime,
                ),
                const SizedBox(width: AppSpacing.md),
                _MetaItem(
                  icon: Icons.calendar_today_outlined,
                  label: days.isEmpty ? '—' : days,
                ),
                const SizedBox(width: AppSpacing.md),
                _MetaItem(
                  icon: Icons.people_outline,
                  label:
                      '${schedule.enrolledPassengerCount}/${schedule.maxCapacity}',
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Manage stops',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.p4),
                    const Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.darkFg3),
        const SizedBox(width: AppSpacing.p4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _TypeBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p6,
        vertical: AppSpacing.p2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Passenger sequence sheet ──────────────────────────────────────────────────

class _PassengerSequenceSheet extends StatefulWidget {
  final DailySchedule schedule;
  const _PassengerSequenceSheet({required this.schedule});

  @override
  State<_PassengerSequenceSheet> createState() =>
      _PassengerSequenceSheetState();
}

class _PassengerSequenceSheetState extends State<_PassengerSequenceSheet> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.85;
    return SizedBox(
      height: h,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.p12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkLine,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadH,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.schedule.name, style: AppTextStyles.h3),
                      Text(
                        'Assign stop sequence for each passenger',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.darkFg2),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.darkLine),
          Expanded(
            child: BlocBuilder<DailyScheduleBloc, DailyScheduleState>(
              builder: (context, state) {
                if (state is DailyScheduleLoading ||
                    state is DailyScheduleMutating) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PassengersLoaded &&
                    state.scheduleId == widget.schedule.id) {
                  if (state.passengers.isEmpty) {
                    return const _EmptyView(
                      icon: Icons.person_off_outlined,
                      message: 'No passengers enrolled',
                      sub: 'Corporate admin needs to enroll employees first.',
                    );
                  }
                  final sorted = [...state.passengers];
                  sorted.sort((a, b) {
                    if (a.stopSequence == null && b.stopSequence == null) {
                      return 0;
                    }
                    if (a.stopSequence == null) {
                      return 1;
                    }
                    if (b.stopSequence == null) {
                      return -1;
                    }
                    return a.stopSequence!.compareTo(b.stopSequence!);
                  });
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pagePadH),
                    itemCount: sorted.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _PassengerRow(
                      passenger: sorted[i],
                      scheduleId: widget.schedule.id,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatefulWidget {
  final DailySchedulePassenger passenger;
  final String scheduleId;
  const _PassengerRow({required this.passenger, required this.scheduleId});

  @override
  State<_PassengerRow> createState() => _PassengerRowState();
}

class _PassengerRowState extends State<_PassengerRow> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.passenger.stopSequence?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = int.tryParse(_ctrl.text.trim());
    if (v == null || v < 1) return;
    context.read<DailyScheduleBloc>().add(
      StopSequenceAssigned(
        scheduleId: widget.scheduleId,
        passengerId: widget.passenger.id,
        sequence: v,
      ),
    );
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final seq = widget.passenger.stopSequence;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: seq == null ? AppColors.warnBg : AppColors.darkLine,
        ),
      ),
      child: Row(
        children: [
          // stop number badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: seq != null ? AppColors.accentBg : AppColors.warnBg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              seq != null ? '#$seq' : '?',
              style: AppTextStyles.label.copyWith(
                color: seq != null ? AppColors.accent : AppColors.warn,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.passenger.employeeName, style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.p2),
                Text(
                  widget.passenger.pickupAddress,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (_editing)
            SizedBox(
              width: 60,
              height: 36,
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: AppTextStyles.h4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBg2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.p7,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() {
                _editing = true;
                _ctrl.text = seq?.toString() ?? '';
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p10,
                  vertical: AppSpacing.p7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBg2,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.darkLine),
                ),
                child: Text(
                  seq != null ? 'Stop $seq' : 'Set',
                  style: AppTextStyles.label.copyWith(
                    color: seq != null ? AppColors.darkFg1 : AppColors.accent,
                  ),
                ),
              ),
            ),
          if (_editing) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p7),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Trips tab ─────────────────────────────────────────────────────────────────

class _TripsTab extends StatelessWidget {
  final DailyScheduleState state;
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _TripsTab({
    required this.state,
    required this.date,
    required this.onPrev,
    required this.onNext,
  });

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get _label {
    if (_isToday) return 'Today';
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadH,
              AppSpacing.md,
              AppSpacing.pagePadH,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.darkFg2,
                  ),
                  onPressed: onPrev,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p6,
                  ),
                  decoration: BoxDecoration(
                    color: _isToday ? AppColors.accentBg : AppColors.darkBg3,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: _isToday ? AppColors.accent : AppColors.darkLine,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: _isToday ? AppColors.accent : AppColors.darkFg2,
                      ),
                      const SizedBox(width: AppSpacing.p6),
                      Text(
                        _label,
                        style: AppTextStyles.label.copyWith(
                          color: _isToday
                              ? AppColors.accent
                              : AppColors.darkFg1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.darkFg2,
                  ),
                  onPressed: onNext,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        if (state is DailyScheduleLoading || state is DailyScheduleMutating)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state is TripsLoaded)
          _buildTripList(context, (state as TripsLoaded).trips)
        else
          const SliverFillRemaining(child: SizedBox()),
      ],
    );
  }

  Widget _buildTripList(BuildContext context, List<DailyTrip> trips) {
    if (trips.isEmpty) {
      return const SliverFillRemaining(
        child: _EmptyView(
          icon: Icons.directions_car_outlined,
          message: 'No trips on this day',
          sub:
              'Scheduled trips will appear here once created by the midnight scheduler.',
        ),
      );
    }

    final unassigned = trips.where((t) => t.needsDriver).toList();
    final assigned = trips.where((t) => !t.needsDriver).toList();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadH,
        0,
        AppSpacing.pagePadH,
        AppSpacing.xl,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (unassigned.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.warn,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Needs driver (${unassigned.length})',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.warn,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...unassigned.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TripCard(trip: t),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (assigned.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.good,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Assigned (${assigned.length})',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.good,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...assigned.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TripCard(trip: t),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Trip card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final DailyTrip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final needsDriver = trip.needsDriver;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadH),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: needsDriver
              ? AppColors.warn.withAlpha(80)
              : AppColors.darkLine,
          width: needsDriver ? 1.5 : 1,
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
                    Text(trip.scheduleName, style: AppTextStyles.h4),
                    const SizedBox(height: AppSpacing.p2),
                    Text(
                      trip.scheduledPickupTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg2,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: trip.status),
            ],
          ),
          const SizedBox(height: AppSpacing.p10),
          // passengers
          ...trip.passengers
              .take(3)
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.p4),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.darkBg3,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p.stopSequence != null ? '${p.stopSequence}' : '?',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkFg2,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          p.employeeName,
                          style: AppTextStyles.bodySm,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _PassengerStatusDot(status: p.status),
                    ],
                  ),
                ),
              ),
          if (trip.passengers.length > 3)
            Text(
              '+${trip.passengers.length - 3} more',
              style: AppTextStyles.caption,
            ),
          const SizedBox(height: AppSpacing.p10),
          const Divider(height: 1, color: AppColors.darkLine),
          const SizedBox(height: AppSpacing.p10),
          if (trip.driverName != null)
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.darkFg3,
                ),
                const SizedBox(width: AppSpacing.p4),
                Text(
                  trip.driverName!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkFg1,
                  ),
                ),
                if (trip.vehiclePlate != null) ...[
                  const SizedBox(width: AppSpacing.p12),
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 14,
                    color: AppColors.darkFg3,
                  ),
                  const SizedBox(width: AppSpacing.p4),
                  Text(
                    trip.vehiclePlate!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkFg1,
                    ),
                  ),
                ],
              ],
            )
          else
            GestureDetector(
              onTap: () => _showAssignDriverSheet(context, trip),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 15,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.p4),
                  Text(
                    'Assign driver',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAssignDriverSheet(BuildContext ctx, DailyTrip trip) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => BlocProvider.value(
        value: ctx.read<DailyScheduleBloc>(),
        child: _AssignDriverSheet(trip: trip),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      BookingStatus.scheduled => (
        'Scheduled',
        AppColors.warn,
        AppColors.warnBg,
      ),
      BookingStatus.driverAssigned => (
        'Assigned',
        AppColors.info,
        AppColors.infoBg,
      ),
      BookingStatus.inProgress => (
        'In Progress',
        AppColors.good,
        AppColors.goodBg,
      ),
      BookingStatus.completed => (
        'Completed',
        AppColors.darkFg2,
        AppColors.darkBg3,
      ),
      BookingStatus.cancelledByEmployee ||
      BookingStatus.cancelledByAdmin ||
      BookingStatus.cancelledByFleetManager ||
      BookingStatus.cancelledByDriver => (
        'Cancelled',
        AppColors.bad,
        AppColors.badBg,
      ),
      _ => (status.displayName, AppColors.darkFg2, AppColors.darkBg3),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p6,
        vertical: AppSpacing.p2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PassengerStatusDot extends StatelessWidget {
  final String status;
  const _PassengerStatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'BOARDED' => AppColors.accent,
      'DROPPED' => AppColors.good,
      'NO_SHOW' => AppColors.bad,
      'CANCELLED' => AppColors.darkFg3,
      _ => AppColors.darkLine,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Assign driver sheet ───────────────────────────────────────────────────────

class _AssignDriverSheet extends StatefulWidget {
  final DailyTrip trip;
  const _AssignDriverSheet({required this.trip});

  @override
  State<_AssignDriverSheet> createState() => _AssignDriverSheetState();
}

class _AssignDriverSheetState extends State<_AssignDriverSheet> {
  List<Driver> _drivers = [];
  List<Vehicle> _vehicles = [];
  String? _selectedDriver;
  String? _selectedVehicle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final driverResult = await getIt<DriverRepo>().list(size: 100);
    final vehicleResult = await getIt<VehicleRepo>().list(size: 100);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (driverResult) {
        case Success(:final value):
          _drivers = value.where((d) => d.availability == 'AVAILABLE').toList();
        case Failure():
          _drivers = [];
      }
      switch (vehicleResult) {
        case Success(:final value):
          _vehicles = value.where((v) => v.status == 'ACTIVE').toList();
        case Failure():
          _vehicles = [];
      }
    });
  }

  void _assign() {
    if (_selectedDriver == null || _selectedVehicle == null) return;
    context.read<DailyScheduleBloc>().add(
      DriverAssigned(
        tripId: widget.trip.id,
        driverId: _selectedDriver!,
        vehicleId: _selectedVehicle!,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.pagePadH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkLine,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Assign Driver', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.p4),
            Text(widget.trip.scheduleName, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text('Driver', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              _DropdownField(
                hint: 'Select available driver',
                value: _selectedDriver,
                items: _drivers
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.fullName, style: AppTextStyles.body),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedDriver = v),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Vehicle', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              _DropdownField(
                hint: 'Select vehicle',
                value: _selectedVehicle,
                items: _vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v.id,
                        child: Text(
                          '${v.plateNumber} · ${v.vehicleType}',
                          style: AppTextStyles.body,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedVehicle = v),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedDriver != null && _selectedVehicle != null)
                      ? _assign
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.accentFg,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.p12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                  child: const Text('Assign Driver', style: AppTextStyles.h4),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p2,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg3),
          ),
          isExpanded: true,
          dropdownColor: AppColors.darkBg3,
          icon: const Icon(Icons.expand_more, color: AppColors.darkFg2),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyView({
    required this.icon,
    required this.message,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.darkFg3),
            const SizedBox(height: AppSpacing.p12),
            Text(message, style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.p4),
            Text(sub, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
          ],
        ),
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
          const Icon(Icons.error_outline, size: 40, color: AppColors.bad),
          const SizedBox(height: AppSpacing.p12),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

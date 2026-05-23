import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/auth/bloc/auth_bloc.dart';
import '../../../../../core/auth/bloc/auth_state.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../daily_schedule/domain/employee_trip.dart';
import '../view_models/employee_roster_view_model.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class EmployeeRosterScreen extends StatefulWidget {
  final EmployeeRosterViewModel viewModel;
  const EmployeeRosterScreen({super.key, required this.viewModel});

  @override
  State<EmployeeRosterScreen> createState() => _EmployeeRosterScreenState();
}

class _EmployeeRosterScreenState extends State<EmployeeRosterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.viewModel.loadMonth());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          body: SafeArea(
            child: Column(
              children: [
                _Header(vm: vm),
                _WeekdayRow(),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : vm.error != null
                          ? _ErrorView(error: vm.error!, onRetry: vm.loadMonth)
                          : _CalendarGrid(vm: vm, context: context),
                ),
                _Legend(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final EmployeeRosterViewModel vm;
  const _Header({required this.vm});

  @override
  Widget build(BuildContext context) {
    final month = vm.focusedMonth;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.darkFg2),
            onPressed: vm.goToPreviousMonth,
          ),
          Expanded(
            child: Text(
              '${_monthNames[month.month - 1]} ${month.year}',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.darkFg2),
            onPressed: vm.goToNextMonth,
          ),
        ],
      ),
    );
  }
}

// ── Weekday row ───────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.darkFg3)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final EmployeeRosterViewModel vm;
  final BuildContext context;
  const _CalendarGrid({required this.vm, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final month = vm.focusedMonth;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // weekday: 1=Mon, 7=Sun → offset so Mon is col 0
    final startOffset = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: rows * 7,
      itemBuilder: (_, index) {
        final dayNum = index - startOffset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();
        final date = DateTime(month.year, month.month, dayNum);
        return _DayCell(
          date: date,
          vm: vm,
          onTap: () => _onDayTap(ctx, date),
        );
      },
    );
  }

  String get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.userId : '';
  }

  void _onDayTap(BuildContext ctx, DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (!date.isAfter(todayDate)) return; // past or today — no action

    final trip = vm.tripFor(date);
    if (trip == null) return; // no trip on this day

    final myPassenger = trip.myPassenger(_currentUserId);
    if (myPassenger == null) return;

    final isSkipped = vm.isSkipped(date);
    showDialog(
      context: ctx,
      builder: (dialogCtx) => _DayActionDialog(
        date: date,
        trip: trip,
        passengerId: myPassenger.id,
        isSkipped: isSkipped,
        vm: vm,
      ),
    );
  }
}

// ── Day cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime date;
  final EmployeeRosterViewModel vm;
  final VoidCallback onTap;
  const _DayCell({required this.date, required this.vm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final isPast = date.isBefore(todayDate);
    final isToday = date == todayDate;
    final hasTrip = vm.hasTrip(date);
    final isSkipped = vm.isSkipped(date);

    Color bg = AppColors.darkBg0;
    Color textColor = AppColors.darkFg0;
    Color? borderColor;
    Widget? indicator;

    if (isPast) {
      textColor = AppColors.darkFg3;
    } else if (isToday) {
      borderColor = AppColors.accent;
      textColor = AppColors.accent;
    }

    if (hasTrip && !isPast) {
      if (isSkipped) {
        bg = AppColors.darkBg2;
        textColor = AppColors.darkFg3;
        indicator = const Icon(Icons.block_rounded, size: 8, color: AppColors.bad);
      } else {
        bg = AppColors.accent.withAlpha(30);
        textColor = AppColors.accent;
        indicator = Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: borderColor != null
              ? Border.all(color: borderColor)
              : Border.all(color: AppColors.darkLine.withAlpha(60)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            if (indicator != null) ...[
              const SizedBox(height: 2),
              indicator,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Day action dialog ─────────────────────────────────────────────────────────

class _DayActionDialog extends StatefulWidget {
  final DateTime date;
  final EmployeeTrip trip;
  final String passengerId;
  final bool isSkipped;
  final EmployeeRosterViewModel vm;
  const _DayActionDialog({
    required this.date,
    required this.trip,
    required this.passengerId,
    required this.isSkipped,
    required this.vm,
  });

  @override
  State<_DayActionDialog> createState() => _DayActionDialogState();
}

class _DayActionDialogState extends State<_DayActionDialog> {
  bool _loading = false;

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final String? err;
    if (widget.isSkipped) {
      err = await widget.vm.undoSkip(widget.passengerId, widget.date);
    } else {
      err = await widget.vm.skipDate(widget.passengerId, widget.date);
    }
    if (!mounted) return;
    Navigator.pop(context);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.bad),
      );
    } else {
      widget.vm.loadMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkBg2,
      title: Text(
        widget.isSkipped ? 'Restore Cab' : 'Skip Cab',
        style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fmtDate(widget.date),
            style: AppTextStyles.body.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.isSkipped
                ? 'Restore your cab booking for this day?'
                : 'Skip your cab for this day? You can restore it later.',
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg1),
          ),
          if (widget.trip.scheduledPickupTime != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(Icons.access_time_rounded, widget.trip.scheduledPickupTime!),
          ],
          _InfoRow(Icons.location_on_rounded, widget.trip.dropAddress),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.darkFg2)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: widget.isSkipped ? AppColors.good : AppColors.bad,
          ),
          onPressed: _loading ? null : _confirm,
          child: _loading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(widget.isSkipped ? 'Restore' : 'Skip'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.darkFg3),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: AppColors.accent.withAlpha(30), label: 'Cab booked'),
          const SizedBox(width: AppSpacing.md),
          _LegendItem(color: AppColors.darkBg2, label: 'Skipped', icon: Icons.block_rounded),
          const SizedBox(width: AppSpacing.md),
          _LegendItem(color: AppColors.darkBg0, label: 'No cab'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;
  const _LegendItem({required this.color, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.darkLine),
          ),
          child: icon != null
              ? Icon(icon, size: 8, color: AppColors.bad)
              : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.darkFg3)),
      ],
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.bad, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(error,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg2),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyles.body.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

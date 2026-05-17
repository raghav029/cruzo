import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/action_item.dart';
import '../../../../../shared/widgets/bar_chart_widget.dart';
import '../../../../../shared/widgets/cruzo_segmented.dart';
import '../../../../../shared/widgets/fleet_bar.dart';
import '../../../../../shared/widgets/kpi_card.dart';
import '../../../../../shared/widgets/section_header.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/dashboard_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) return const _LoadingView();
          if (state is DashboardError)
            return _ErrorView(message: state.message);
          if (state is DashboardLoaded)
            return _DashboardContent(summary: state.summary);
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Main content ────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final DashboardSummary summary;
  const _DashboardContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final pad = isWide ? 24.0 : 16.0;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DashboardBloc>().add(const DashboardRefreshRequested()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 20),

            // ── Today KPIs ──────────────────────────────────────────────────
            SectionHeader(
              title: "Today's Operations",
              actionLabel: 'View all trips',
              onAction: () => context.go(AppRoutes.fleetDailyTripsPath),
            ),
            const SizedBox(height: 12),
            _KpiGrid(
              children: [
                KpiCard(
                  label: 'TRIPS TODAY',
                  value: '${summary.tripsToday}',
                  subtitle: '${summary.activeTrips} in progress',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.accent,
                  bgColor: AppColors.accentBg,
                  onTap: () => context.go(AppRoutes.fleetDailyTripsPath),
                  sparkData: summary.tripsSparkData.isEmpty ? null : summary.tripsSparkData,
                ),
                KpiCard(
                  label: 'ACTIVE TRIPS',
                  value: '${summary.activeTrips}',
                  subtitle: 'Currently on road',
                  icon: Icons.directions_car_rounded,
                  color: AppColors.good,
                  bgColor: AppColors.goodBg,
                  sparkData: summary.tripsSparkData.isEmpty ? null : summary.tripsSparkData,
                ),
                KpiCard(
                  label: 'UNASSIGNED',
                  value: '${summary.unassignedTrips}',
                  subtitle: summary.unassignedTrips > 0
                      ? 'Need driver assignment'
                      : 'All assigned',
                  icon: Icons.assignment_late_rounded,
                  color: summary.unassignedTrips > 0
                      ? AppColors.warn
                      : AppColors.good,
                  bgColor: summary.unassignedTrips > 0
                      ? AppColors.warnBg
                      : AppColors.goodBg,
                  onTap: () => context.go(AppRoutes.fleetDailyTripsPath),
                  sparkData: summary.unassignedSparkData.isEmpty ? null : summary.unassignedSparkData,
                ),
                KpiCard(
                  label: 'PENDING APPROVALS',
                  value: '${summary.pendingApprovals}',
                  subtitle: 'Awaiting review',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.info,
                  bgColor: AppColors.infoBg,
                  onTap: () => context.go(AppRoutes.fleetBookingsPath),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Trips by hour chart + Fleet status ──────────────────────────
            _isWide(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _TripsByHourCard(summary: summary)),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: _FleetStatusCard(summary: summary)),
                    ],
                  )
                : Column(
                    children: [
                      _TripsByHourCard(summary: summary),
                      const SizedBox(height: 16),
                      _FleetStatusCard(summary: summary),
                    ],
                  ),

            const SizedBox(height: 24),

            // ── Action queue ────────────────────────────────────────────────
            _ActionQueueCard(summary: summary),

            const SizedBox(height: 24),

            // ── Monthly overview ────────────────────────────────────────────
            const SectionHeader(title: 'This Month'),
            const SizedBox(height: 12),
            _KpiGrid(
              children: [
                KpiCard(
                  label: 'TOTAL BOOKINGS',
                  value: '${summary.totalBookingsThisMonth}',
                  icon: Icons.book_online_rounded,
                  color: AppColors.accent,
                  bgColor: AppColors.accentBg,
                  onTap: () => context.go(AppRoutes.fleetBookingsPath),
                ),
                KpiCard(
                  label: 'REVENUE',
                  value: '₹${_fmt(summary.revenueThisMonth)}',
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.good,
                  bgColor: AppColors.goodBg,
                  onTap: () => context.go(AppRoutes.fleetReportsPath),
                ),
                KpiCard(
                  label: 'PENDING INVOICES',
                  value: '${summary.pendingInvoices}',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.info,
                  bgColor: AppColors.infoBg,
                  onTap: () => context.go(AppRoutes.fleetInvoicesPath),
                ),
                KpiCard(
                  label: 'EXPIRING DOCS',
                  value: '${summary.expiringDocuments}',
                  subtitle: 'Next 30 days',
                  icon: Icons.description_outlined,
                  color: summary.expiringDocuments > 0
                      ? AppColors.warn
                      : AppColors.good,
                  bgColor: summary.expiringDocuments > 0
                      ? AppColors.warnBg
                      : AppColors.goodBg,
                  onTap: () => context.go(AppRoutes.fleetDocumentsPath),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 800;

  String _fmt(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

// ─── Responsive KPI grid ──────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final List<Widget> children;
  const _KpiGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    final cols = _cols(context);
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += cols) {
      final slice = children.sublist(i, (i + cols).clamp(0, children.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < slice.length; j++) ...[
                if (j > 0) const SizedBox(width: 12),
                Expanded(child: slice[j]),
              ],
              for (int j = slice.length; j < cols; j++) ...[
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ),
      );
      if (i + cols < children.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  int _cols(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 4;
    if (w >= 800) return 2;
    return 2;
  }
}

// ─── Trips by hour card ───────────────────────────────────────────────────────

class _TripsByHourCard extends StatefulWidget {
  final DashboardSummary summary;
  const _TripsByHourCard({required this.summary});

  @override
  State<_TripsByHourCard> createState() => _TripsByHourCardState();
}

class _TripsByHourCardState extends State<_TripsByHourCard> {
  int _seg = 0;

  List<BarChartData> _toBarData(List<TripHourStat> stats) =>
      stats.map((s) => BarChartData(label: s.label, value: s.value)).toList();

  @override
  Widget build(BuildContext context) {
    final datasets = [
      _toBarData(widget.summary.tripsByHourToday),
      _toBarData(widget.summary.tripsByHour7d),
      _toBarData(widget.summary.tripsByHour30d),
    ];
    final data = datasets[_seg];

    return _Card(
      title: 'Trips by hour',
      subtitle: 'Bookings combined · IST',
      action: CruzoSegmented(
        labels: const ['Today', '7d', '30d'],
        selected: _seg,
        onChanged: (i) => setState(() => _seg = i),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: data.isEmpty
            ? const SizedBox(
                height: 160,
                child: Center(
                  child: Text('No data', style: TextStyle(color: AppColors.darkFg3, fontSize: 12)),
                ),
              )
            : BarChartWidget(data: data, height: 160, color: AppColors.accent),
      ),
    );
  }
}

// ─── Fleet status card ────────────────────────────────────────────────────────

class _FleetStatusCard extends StatelessWidget {
  final DashboardSummary summary;
  const _FleetStatusCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final vehiclesAvailable = summary.totalVehicles - summary.vehiclesInTrip;
    final driversOnTrip = summary.totalDrivers - summary.availableDrivers;

    return _Card(
      title: 'Fleet Status',
      subtitle:
          '${summary.totalVehicles} vehicles · ${summary.totalDrivers} drivers',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            FleetBar(
              label: 'Vehicles',
              total: summary.totalVehicles,
              segments: [
                FleetBarSegment(
                  label: 'Available',
                  count: vehiclesAvailable,
                  color: AppColors.good,
                ),
                FleetBarSegment(
                  label: 'In Trip',
                  count: summary.vehiclesInTrip,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FleetBar(
              label: 'Drivers',
              total: summary.totalDrivers,
              segments: [
                FleetBarSegment(
                  label: 'Available',
                  count: summary.availableDrivers,
                  color: AppColors.good,
                ),
                FleetBarSegment(
                  label: 'On Trip',
                  count: driversOnTrip,
                  color: AppColors.accent,
                ),
              ],
            ),
            if (summary.activeSosAlerts > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.bad.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sos_rounded,
                      size: 16,
                      color: AppColors.bad,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${summary.activeSosAlerts} active SOS alert${summary.activeSosAlerts > 1 ? 's' : ''} — needs immediate attention',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.bad,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.fleetSosAlertsPath),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.bad,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 12)),
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
}

// ─── Action queue card ────────────────────────────────────────────────────────

class _ActionQueueCard extends StatelessWidget {
  final DashboardSummary summary;
  const _ActionQueueCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return _Card(
      title: 'Action Queue',
      subtitle: 'Things needing you',
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'All caught up!',
                  style: TextStyle(color: AppColors.darkFg3, fontSize: 13),
                ),
              ),
            )
          : Column(
              children: items
                  .map(
                    (item) => ActionItem(
                      icon: item.$1,
                      iconColor: item.$2,
                      title: item.$3,
                      subtitle: item.$4,
                      ctaLabel: item.$5,
                      onCta: item.$6,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  List<(IconData, Color, String, String, String, VoidCallback?)> _buildItems(
    BuildContext context,
  ) {
    final items = <(IconData, Color, String, String, String, VoidCallback?)>[];

    if (summary.activeSosAlerts > 0) {
      items.add((
        Icons.sos_rounded,
        AppColors.bad,
        '${summary.activeSosAlerts} active SOS alert${summary.activeSosAlerts > 1 ? 's' : ''}',
        'Requires immediate attention',
        'Respond',
        () => context.go(AppRoutes.fleetSosAlertsPath),
      ));
    }

    if (summary.unassignedTrips > 0) {
      items.add((
        Icons.assignment_late_rounded,
        AppColors.warn,
        '${summary.unassignedTrips} unassigned trip${summary.unassignedTrips > 1 ? 's' : ''}',
        'Assign drivers before departure',
        'Assign',
        () => context.go(AppRoutes.fleetDailyTripsPath),
      ));
    }

    if (summary.pendingApprovals > 0) {
      items.add((
        Icons.pending_actions_rounded,
        AppColors.info,
        '${summary.pendingApprovals} booking${summary.pendingApprovals > 1 ? 's' : ''} pending approval',
        'Review and approve or reject',
        'Review',
        () => context.go(AppRoutes.fleetBookingsPath),
      ));
    }

    if (summary.pendingInvoices > 0) {
      items.add((
        Icons.receipt_long_outlined,
        AppColors.info,
        '${summary.pendingInvoices} invoice${summary.pendingInvoices > 1 ? 's' : ''} to send',
        'Draft invoices ready to dispatch',
        'Send',
        () => context.go(AppRoutes.fleetInvoicesPath),
      ));
    }

    if (summary.expiringDocuments > 0) {
      items.add((
        Icons.description_outlined,
        AppColors.warn,
        '${summary.expiringDocuments} document${summary.expiringDocuments > 1 ? 's' : ''} expiring',
        'Licenses or permits due in 30 days',
        'Update',
        () => context.go(AppRoutes.fleetDocumentsPath),
      ));
    }

    return items;
  }
}

// ─── Reusable card shell ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  const _Card({required this.title, required this.child, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
        boxShadow: AppShadows.shadow1Dark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.darkFg0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.darkFg3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.darkLine),
          child,
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0),
            ),
            const SizedBox(height: 2),
            Text(
              '$greeting, Fleet Manager',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
            ),
          ],
        ),
        IconButton(
          onPressed: () => context.read<DashboardBloc>().add(
            const DashboardRefreshRequested(),
          ),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.darkFg2),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

// ─── Loading / Error ──────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.bad),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

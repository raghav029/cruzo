import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/alert_badge.dart';
import '../../../../../shared/widgets/section_header.dart';
import '../../../../../shared/widgets/stat_card.dart';
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
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) return const _LoadingView();
          if (state is DashboardError) return _ErrorView(message: state.message);
          if (state is DashboardLoaded) return _DashboardContent(summary: state.summary);
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardSummary summary;
  const _DashboardContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 20),

            // Alert row — urgent items first
            if (summary.activeSosAlerts > 0 ||
                summary.unassignedTrips > 0 ||
                summary.expiringDocuments > 0)
              _AlertRow(summary: summary),

            const SizedBox(height: 24),

            // Today's Operations
            const SectionHeader(title: "Today's Operations"),
            const SizedBox(height: 12),
            _TodayGrid(summary: summary),

            const SizedBox(height: 24),

            // Fleet Status
            const SectionHeader(title: 'Fleet Status'),
            const SizedBox(height: 12),
            _FleetGrid(summary: summary),

            const SizedBox(height: 24),

            // Monthly Overview
            const SectionHeader(title: 'This Month'),
            const SizedBox(height: 12),
            _MonthlyGrid(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTextStyles.h2),
            const SizedBox(height: 2),
            Text('Welcome back, Fleet Manager', style: AppTextStyles.bodySm),
          ],
        ),
        IconButton(
          onPressed: () => context.read<DashboardBloc>().add(const DashboardRefreshRequested()),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.grey500),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  final DashboardSummary summary;
  const _AlertRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (summary.activeSosAlerts > 0)
          AlertBadge(
            label: 'Active SOS',
            count: summary.activeSosAlerts,
            color: AppColors.error,
            bgColor: AppColors.errorLight,
            icon: Icons.sos_rounded,
          ),
        if (summary.unassignedTrips > 0)
          AlertBadge(
            label: 'Unassigned Trips',
            count: summary.unassignedTrips,
            color: AppColors.warning,
            bgColor: AppColors.warningLight,
            icon: Icons.directions_car_outlined,
          ),
        if (summary.pendingApprovals > 0)
          AlertBadge(
            label: 'Pending Approvals',
            count: summary.pendingApprovals,
            color: AppColors.info,
            bgColor: AppColors.infoLight,
            icon: Icons.pending_actions_rounded,
          ),
        if (summary.expiringDocuments > 0)
          AlertBadge(
            label: 'Expiring Docs',
            count: summary.expiringDocuments,
            color: AppColors.warning,
            bgColor: AppColors.warningLight,
            icon: Icons.description_outlined,
          ),
      ],
    );
  }
}

class _TodayGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _TodayGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _crossAxisCount(context),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Trips Today',
          value: '${summary.tripsToday}',
          icon: Icons.calendar_today_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
        ),
        StatCard(
          title: 'Active Trips',
          value: '${summary.activeTrips}',
          icon: Icons.directions_car_rounded,
          color: AppColors.success,
          bgColor: AppColors.successLight,
          subtitle: 'Currently in progress',
        ),
        StatCard(
          title: 'Unassigned Trips',
          value: '${summary.unassignedTrips}',
          icon: Icons.assignment_late_rounded,
          color: summary.unassignedTrips > 0 ? AppColors.warning : AppColors.success,
          bgColor: summary.unassignedTrips > 0 ? AppColors.warningLight : AppColors.successLight,
          subtitle: summary.unassignedTrips > 0 ? 'Need driver assignment' : 'All assigned',
        ),
        StatCard(
          title: 'Pending Approvals',
          value: '${summary.pendingApprovals}',
          icon: Icons.pending_actions_rounded,
          color: AppColors.info,
          bgColor: AppColors.infoLight,
        ),
      ],
    );
  }
}

class _FleetGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _FleetGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _crossAxisCount(context),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Total Vehicles',
          value: '${summary.totalVehicles}',
          icon: Icons.directions_car_outlined,
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
          subtitle: '${summary.vehiclesInTrip} in trip',
        ),
        StatCard(
          title: 'Available Vehicles',
          value: '${summary.totalVehicles - summary.vehiclesInTrip}',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
          bgColor: AppColors.successLight,
        ),
        StatCard(
          title: 'Total Drivers',
          value: '${summary.totalDrivers}',
          icon: Icons.badge_outlined,
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
          subtitle: '${summary.availableDrivers} available',
        ),
        StatCard(
          title: 'Active SOS Alerts',
          value: '${summary.activeSosAlerts}',
          icon: Icons.sos_rounded,
          color: summary.activeSosAlerts > 0 ? AppColors.error : AppColors.success,
          bgColor: summary.activeSosAlerts > 0 ? AppColors.errorLight : AppColors.successLight,
          subtitle: summary.activeSosAlerts == 0 ? 'All clear' : 'Needs attention',
        ),
      ],
    );
  }
}

class _MonthlyGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _MonthlyGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _crossAxisCount(context),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Total Bookings',
          value: '${summary.totalBookingsThisMonth}',
          icon: Icons.book_online_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
        ),
        StatCard(
          title: 'Revenue',
          value: '₹${_formatAmount(summary.revenueThisMonth)}',
          icon: Icons.currency_rupee_rounded,
          color: AppColors.success,
          bgColor: AppColors.successLight,
        ),
        StatCard(
          title: 'Pending Invoices',
          value: '${summary.pendingInvoices}',
          icon: Icons.receipt_long_outlined,
          color: AppColors.info,
          bgColor: AppColors.infoLight,
        ),
        StatCard(
          title: 'Expiring Documents',
          value: '${summary.expiringDocuments}',
          icon: Icons.description_outlined,
          color: summary.expiringDocuments > 0 ? AppColors.warning : AppColors.success,
          bgColor: summary.expiringDocuments > 0 ? AppColors.warningLight : AppColors.successLight,
          subtitle: 'Next 30 days',
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

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
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DashboardBloc>().add(const DashboardLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

int _crossAxisCount(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 1200) return 4;
  if (width >= 800) return 3;
  return 2;
}

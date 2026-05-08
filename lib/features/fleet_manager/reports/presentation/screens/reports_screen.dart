import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/network/result.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/cruzo_card.dart';
import '../../../../../shared/widgets/stat_card.dart';
import '../../../../fleet_manager/clients/domain/client_repo.dart';
import '../../../../fleet_manager/clients/domain/corporate_client.dart';
import '../../domain/report_models.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // shared date range (defaults to current month)
  late DateTime _from;
  late DateTime _to;

  // corporate spend
  List<CorporateClient> _clients = [];
  CorporateClient? _selectedClient;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = now;
    _loadFleetSummary();
    _loadClients();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String get _fromStr => _from.toIso8601String().split('T').first;
  String get _toStr => _to.toIso8601String().split('T').first;

  void _loadFleetSummary() {
    context.read<ReportBloc>().add(
          FleetSummaryRequested(fromDate: _fromStr, toDate: _toStr),
        );
  }

  void _loadCorporateSpend() {
    if (_selectedClient == null) return;
    context.read<ReportBloc>().add(
          CorporateSpendRequested(
            corporateClientId: _selectedClient!.id,
            fromDate: _fromStr,
            toDate: _toStr,
          ),
        );
  }

  Future<void> _loadClients() async {
    final result = await getIt<ClientRepo>().list(size: 100);
    if (result case Success(:final value)) {
      if (mounted) setState(() => _clients = value);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.darkBg2,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _from = picked.start;
      _to = picked.end;
    });
    if (_tab.index == 0) {
      _loadFleetSummary();
    } else {
      _loadCorporateSpend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reports', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(
                        'Analytics and performance insights',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.darkFg2),
                      ),
                    ],
                  ),
                ),
                // Date range pill
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkLine),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range_outlined,
                            size: 14, color: AppColors.darkFg2),
                        const SizedBox(width: 6),
                        Text(
                          '${dateFmt.format(_from)} – ${dateFmt.format(_to)}',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.darkFg1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Tabs ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: TabBar(
              controller: _tab,
              isScrollable: false,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.darkFg2,
              indicatorColor: AppColors.accent,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.darkLine,
              tabs: const [
                Tab(text: 'Fleet Summary'),
                Tab(text: 'Corporate Spend'),
              ],
              onTap: (i) {
                if (i == 0) {
                  _loadFleetSummary();
                } else if (_selectedClient != null) {
                  _loadCorporateSpend();
                }
              },
            ),
          ),
          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _FleetSummaryTab(onRefresh: _loadFleetSummary),
                _CorporateSpendTab(
                  clients: _clients,
                  selected: _selectedClient,
                  onClientChanged: (c) {
                    setState(() => _selectedClient = c);
                    _loadCorporateSpend();
                  },
                  onRefresh: _loadCorporateSpend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fleet Summary tab ─────────────────────────────────────────────────────────

class _FleetSummaryTab extends StatelessWidget {
  const _FleetSummaryTab({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportError) {
          return _ErrorView(message: state.message, onRetry: onRefresh);
        }
        if (state is FleetSummaryLoaded) {
          return _FleetSummaryContent(summary: state.summary);
        }
        return const Center(
          child: Text('Select date range to load report',
              style: AppTextStyles.body),
        );
      },
    );
  }
}

class _FleetSummaryContent extends StatelessWidget {
  const _FleetSummaryContent({required this.summary});
  final FleetSummary summary;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI grid
          _KpiGrid(
            kpis: [
              ('Total Bookings', '${summary.totalBookings}',
                  Icons.calendar_today_outlined, AppColors.accent),
              ('Completed', '${summary.completedBookings}',
                  Icons.check_circle_outline, AppColors.good),
              ('Cancelled', '${summary.cancelledBookings}',
                  Icons.cancel_outlined, AppColors.bad),
              ('Revenue', _inr.format(summary.totalRevenue),
                  Icons.currency_rupee_rounded, AppColors.warn),
              ('Avg Fare', _inr.format(summary.averageFare),
                  Icons.receipt_outlined, AppColors.darkFg2),
            ],
          ),
          const SizedBox(height: 16),
          // Top drivers
          if (summary.topDrivers.isNotEmpty)
            CruzoCard(
              title: 'Top Drivers',
              subtitle: '${summary.topDrivers.length} drivers',
              flush: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summary.topDrivers.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.darkLine),
                itemBuilder: (_, i) {
                  final d = summary.topDrivers[i];
                  return _RankRow(
                    rank: i + 1,
                    title: d.driverName,
                    subtitle: '${d.completedTrips} trips completed',
                    icon: Icons.person_outline_rounded,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          // Vehicle utilization
          if (summary.vehicleUtilization.isNotEmpty)
            CruzoCard(
              title: 'Vehicle Utilization',
              subtitle: '${summary.vehicleUtilization.length} vehicles',
              flush: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: summary.vehicleUtilization.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.darkLine),
                itemBuilder: (_, i) {
                  final v = summary.vehicleUtilization[i];
                  return _RankRow(
                    rank: i + 1,
                    title: v.plateNumber,
                    subtitle: '${v.vehicleType} · ${v.trips} trips',
                    icon: Icons.directions_car_outlined,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Corporate Spend tab ───────────────────────────────────────────────────────

class _CorporateSpendTab extends StatelessWidget {
  const _CorporateSpendTab({
    required this.clients,
    required this.selected,
    required this.onClientChanged,
    required this.onRefresh,
  });
  final List<CorporateClient> clients;
  final CorporateClient? selected;
  final void Function(CorporateClient?) onClientChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Client picker
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: DropdownButtonFormField<CorporateClient>(
            value: selected,
            isExpanded: true,
            dropdownColor: AppColors.darkBg2,
            style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
            decoration: InputDecoration(
              hintText: clients.isEmpty
                  ? 'Loading clients…'
                  : 'Select corporate client',
              hintStyle:
                  AppTextStyles.bodySm.copyWith(color: AppColors.darkFg3),
              filled: true,
              fillColor: AppColors.darkBg3,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.darkLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.darkLine),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: clients
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.companyName),
                    ))
                .toList(),
            onChanged: onClientChanged,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (selected == null) {
                return const Center(
                  child: Text('Select a client to view spend report',
                      style: AppTextStyles.body),
                );
              }
              if (state is ReportLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ReportError) {
                return _ErrorView(message: state.message, onRetry: onRefresh);
              }
              if (state is CorporateSpendLoaded) {
                return _CorporateSpendContent(spend: state.spend);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _CorporateSpendContent extends StatelessWidget {
  const _CorporateSpendContent({required this.spend});
  final CorporateSpend spend;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KpiGrid(
            kpis: [
              ('Total Bookings', '${spend.totalBookings}',
                  Icons.calendar_today_outlined, AppColors.accent),
              ('Total Spend', _inr.format(spend.totalSpend),
                  Icons.currency_rupee_rounded, AppColors.warn),
            ],
          ),
          const SizedBox(height: 16),
          if (spend.topEmployees.isNotEmpty)
            CruzoCard(
              title: 'Top Employees',
              subtitle: '${spend.topEmployees.length} employees',
              flush: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: spend.topEmployees.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.darkLine),
                itemBuilder: (_, i) {
                  final e = spend.topEmployees[i];
                  return _RankRow(
                    rank: i + 1,
                    title: e.employeeName,
                    subtitle:
                        '${e.trips} trips · ${_inr.format(e.totalSpend)}',
                    icon: Icons.badge_outlined,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          if (spend.monthlyBreakdown.isNotEmpty)
            CruzoCard(
              title: 'Monthly Breakdown',
              flush: true,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: spend.monthlyBreakdown.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.darkLine),
                itemBuilder: (_, i) {
                  final m = spend.monthlyBreakdown[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          m.month,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.darkFg0),
                        ),
                        const Spacer(),
                        Text(
                          '${m.trips} trips',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.darkFg2),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _inr.format(m.spend),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.darkFg0,
                            fontWeight: FontWeight.w600,
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});
  final List<(String, String, IconData, Color)> kpis;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    return GridView.count(
      crossAxisCount: isWide ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: kpis
          .map((k) => StatCard(
                title: k.$1,
                value: k.$2,
                icon: k.$3,
                color: k.$4,
                bgColor: k.$4.withAlpha(26),
              ))
          .toList(),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final int rank;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.darkFg3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: AppColors.darkFg2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.darkFg0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.darkFg2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.bad),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

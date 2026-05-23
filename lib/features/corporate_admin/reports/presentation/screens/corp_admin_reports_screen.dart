import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/cruzo_card.dart';
import '../../../../../shared/widgets/stat_card.dart';
import '../../../../fleet_manager/reports/domain/report_models.dart';
import '../../../../fleet_manager/reports/presentation/bloc/report_bloc.dart';
import '../../../../fleet_manager/reports/presentation/bloc/report_event.dart';
import '../../../../fleet_manager/reports/presentation/bloc/report_state.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class CorpAdminReportsScreen extends StatefulWidget {
  const CorpAdminReportsScreen({super.key});

  @override
  State<CorpAdminReportsScreen> createState() => _CorpAdminReportsScreenState();
}

class _CorpAdminReportsScreenState extends State<CorpAdminReportsScreen> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = now;
    _load();
  }

  String get _fromStr => _from.toIso8601String().split('T').first;
  String get _toStr => _to.toIso8601String().split('T').first;

  void _load() {
    context.read<ReportBloc>().add(
          CorporateSpendRequested(fromDate: _fromStr, toDate: _toStr),
        );
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
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spend Reports', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(
                        'Your company\'s booking spend',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ReportError) {
                  return _ErrorView(message: state.message, onRetry: _load);
                }
                if (state is CorporateSpendLoaded) {
                  return _SpendContent(spend: state.spend);
                }
                return const Center(
                  child: Text('Loading…', style: AppTextStyles.body),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendContent extends StatelessWidget {
  const _SpendContent({required this.spend});
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
              title: 'Top Employees by Spend',
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
                    subtitle: '${e.trips} trips · ${_inr.format(e.totalSpend)}',
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

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});
  final List<(String, String, IconData, Color)> kpis;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
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
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
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

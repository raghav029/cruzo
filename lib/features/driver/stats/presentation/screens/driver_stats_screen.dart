import 'package:flutter/material.dart';
import 'package:cruzo/core/theme/dls/dls.dart';
import 'package:cruzo/core/di/injection.dart';
import 'package:cruzo/shared/widgets/stat_card.dart';
import 'package:cruzo/shared/widgets/app_error_view.dart';
import '../view_models/driver_stats_view_model.dart';

class DriverStatsScreen extends StatefulWidget {
  const DriverStatsScreen({super.key});

  @override
  State<DriverStatsScreen> createState() => _DriverStatsScreenState();
}

class _DriverStatsScreenState extends State<DriverStatsScreen> {
  late final DriverStatsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<DriverStatsViewModel>();
    _vm.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.darkBg1,
          appBar: AppBar(
            backgroundColor: AppColors.darkBg0,
            title: Text('My Stats', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkFg1),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.darkFg2),
                onPressed: _vm.load,
              ),
            ],
          ),
          body: SafeArea(
            child: _vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _vm.error != null
                    ? AppErrorView(message: _vm.error!, onRetry: _vm.load)
                    : _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final s = _vm.stats ?? {};
    final totalTrips = s['totalTrips'] as int? ?? 0;
    final tripsMonth = s['tripsThisMonth'] as int? ?? 0;
    final totalEarnings = (s['totalEarnings'] as num?)?.toDouble() ?? 0.0;
    final monthEarnings = (s['earningsThisMonth'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadH,
        vertical: AppSpacing.pagePadV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: AppTextStyles.h3.copyWith(color: AppColors.darkFg2)),
          const SizedBox(height: AppSpacing.md),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.6,
            ),
            children: [
              StatCard(
                title: 'Total Trips',
                value: '$totalTrips',
                icon: Icons.directions_car_rounded,
                color: AppColors.accent,
                bgColor: AppColors.accentBg,
              ),
              StatCard(
                title: 'This Month',
                value: '$tripsMonth',
                icon: Icons.calendar_today_outlined,
                color: AppColors.info,
                bgColor: AppColors.infoBg,
              ),
              StatCard(
                title: 'Total Earnings',
                value: '₹${totalEarnings.toStringAsFixed(0)}',
                icon: Icons.currency_rupee,
                color: AppColors.good,
                bgColor: AppColors.goodBg,
              ),
              StatCard(
                title: 'Month Earnings',
                value: '₹${monthEarnings.toStringAsFixed(0)}',
                icon: Icons.trending_up_rounded,
                color: AppColors.warn,
                bgColor: AppColors.warnBg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

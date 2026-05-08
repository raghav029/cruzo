import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/cruzo_card.dart';
import '../../domain/document_expiry.dart';
import '../bloc/document_expiry_bloc.dart';
import '../bloc/document_expiry_event.dart';
import '../bloc/document_expiry_state.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentExpiryBloc>().add(const DocumentExpiryLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: BlocBuilder<DocumentExpiryBloc, DocumentExpiryState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: _Header(
                    count: state is DocumentExpiryLoaded
                        ? state.summary.totalCount
                        : null,
                    onRefresh: () => context
                        .read<DocumentExpiryBloc>()
                        .add(const DocumentExpiryLoadRequested()),
                  ),
                ),
              ),
              if (state is DocumentExpiryLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is DocumentExpiryError)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<DocumentExpiryBloc>()
                        .add(const DocumentExpiryLoadRequested()),
                  ),
                )
              else if (state is DocumentExpiryLoaded) ...[
                if (state.summary.totalCount == 0)
                  const SliverFillRemaining(child: _EmptyView())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (state.summary.expiringLicenses.isNotEmpty) ...[
                          _DriverSection(
                            title: 'Driver Licenses',
                            icon: Icons.badge_outlined,
                            items: state.summary.expiringLicenses,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.summary.expiringDriverInsurance.isNotEmpty) ...[
                          _DriverSection(
                            title: 'Driver Insurance',
                            icon: Icons.health_and_safety_outlined,
                            items: state.summary.expiringDriverInsurance,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.summary.expiringVehicleInsurance.isNotEmpty) ...[
                          _VehicleSection(
                            title: 'Vehicle Insurance',
                            icon: Icons.car_crash_outlined,
                            items: state.summary.expiringVehicleInsurance,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.summary.expiringFitnessCerts.isNotEmpty) ...[
                          _VehicleSection(
                            title: 'Fitness Certificates',
                            icon: Icons.assignment_outlined,
                            items: state.summary.expiringFitnessCerts,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ]),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({this.count, required this.onRefresh});
  final int? count;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document Expiry', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(
                count == null
                    ? 'Documents expiring within 30 days'
                    : count! == 0
                        ? 'All documents up to date'
                        : '$count document${count! > 1 ? 's' : ''} expiring within 30 days',
                style: AppTextStyles.bodySm.copyWith(
                  color: (count ?? 0) > 0 ? AppColors.warn : AppColors.darkFg2,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, color: AppColors.darkFg2),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

// ── Driver section ────────────────────────────────────────────────────────────

class _DriverSection extends StatelessWidget {
  const _DriverSection({
    required this.title,
    required this.icon,
    required this.items,
  });
  final String title;
  final IconData icon;
  final List<DriverExpiryItem> items;

  @override
  Widget build(BuildContext context) {
    return CruzoCard(
      title: title,
      subtitle: '${items.length} expiring',
      flush: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.darkLine),
        itemBuilder: (_, i) => _DriverRow(item: items[i], icon: icon),
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.item, required this.icon});
  final DriverExpiryItem item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _fgColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.driverName,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.darkFg0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.phone,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.expiryDate,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.darkFg1, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              _DaysBadge(days: item.daysUntilExpiry),
            ],
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    if (item.isExpired) return AppColors.badBg;
    if (item.isCritical) return AppColors.badBg;
    return AppColors.warnBg;
  }

  Color get _fgColor {
    if (item.isExpired) return AppColors.bad;
    if (item.isCritical) return AppColors.bad;
    return AppColors.warn;
  }
}

// ── Vehicle section ───────────────────────────────────────────────────────────

class _VehicleSection extends StatelessWidget {
  const _VehicleSection({
    required this.title,
    required this.icon,
    required this.items,
  });
  final String title;
  final IconData icon;
  final List<VehicleExpiryItem> items;

  @override
  Widget build(BuildContext context) {
    return CruzoCard(
      title: title,
      subtitle: '${items.length} expiring',
      flush: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.darkLine),
        itemBuilder: (_, i) => _VehicleRow(item: items[i], icon: icon),
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.item, required this.icon});
  final VehicleExpiryItem item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _fgColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.plateNumber,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.darkFg0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.make} ${item.model}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.expiryDate,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.darkFg1, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              _DaysBadge(days: item.daysUntilExpiry),
            ],
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    if (item.isExpired) return AppColors.badBg;
    if (item.isCritical) return AppColors.badBg;
    return AppColors.warnBg;
  }

  Color get _fgColor {
    if (item.isExpired) return AppColors.bad;
    if (item.isCritical) return AppColors.bad;
    return AppColors.warn;
  }
}

// ── Days badge ────────────────────────────────────────────────────────────────

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = days <= 0
        ? ('Expired', AppColors.bad, AppColors.badBg)
        : days <= 7
            ? ('$days days', AppColors.bad, AppColors.badBg)
            : ('$days days', AppColors.warn, AppColors.warnBg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_outlined, size: 48, color: AppColors.good),
        SizedBox(height: 12),
        Text('All documents up to date', style: AppTextStyles.body),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.bad),
        const SizedBox(height: 12),
        Text(message, style: AppTextStyles.body),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

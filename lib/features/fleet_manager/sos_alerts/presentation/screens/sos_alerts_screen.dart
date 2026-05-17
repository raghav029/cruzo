import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../../../../shared/widgets/cruzo_card.dart';
import '../../../../../shared/widgets/status_tag.dart';
import '../../domain/sos_alert.dart';
import '../bloc/sos_alert_bloc.dart';
import '../bloc/sos_alert_event.dart';
import '../bloc/sos_alert_state.dart';

class SosAlertsScreen extends StatefulWidget {
  const SosAlertsScreen({super.key});

  @override
  State<SosAlertsScreen> createState() => _SosAlertsScreenState();
}

class _SosAlertsScreenState extends State<SosAlertsScreen> {
  String? _filter; // null = all, 'ACTIVE', 'RESOLVED'

  @override
  void initState() {
    super.initState();
    context.read<SosAlertBloc>().add(const SosAlertLoadRequested());
  }

  void _applyFilter(String? status) {
    setState(() => _filter = status);
    context.read<SosAlertBloc>().add(
      SosAlertLoadRequested(statusFilter: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SosAlertBloc, SosAlertState>(
      listener: (context, state) {
        if (state is SosAlertMutationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.good,
            ),
          );
        } else if (state is SosAlertMutationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.bad,
            ),
          );
        }
      },
      builder: (context, state) {
        final alerts = switch (state) {
          SosAlertLoaded(:final alerts) => alerts,
          SosAlertMutating(:final alerts) => alerts,
          SosAlertMutationSuccess(:final alerts) => alerts,
          SosAlertMutationError(:final alerts) => alerts,
          _ => <SosAlert>[],
        };
        final loading = state is SosAlertLoading;
        final active = alerts.where((a) => a.isActive).length;

        return Container(
          color: AppColors.darkBg1,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: _Header(activeCount: active),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _FilterBar(active: _filter, onFilter: _applyFilter),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: CruzoCard(
                    title: 'Alerts',
                    subtitle: loading ? null : '${alerts.length} total',
                    flush: true,
                    child: _Body(
                      loading: loading,
                      error: state is SosAlertError ? state.message : null,
                      alerts: alerts,
                      onRetry: () => _applyFilter(_filter),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.activeCount});
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SOS Alerts', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(
                activeCount > 0
                    ? '$activeCount active alert${activeCount > 1 ? 's' : ''} need attention'
                    : 'No active alerts',
                style: AppTextStyles.bodySm.copyWith(
                  color: activeCount > 0 ? AppColors.bad : AppColors.darkFg2,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              context.read<SosAlertBloc>().add(const SosAlertLoadRequested()),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.darkFg2),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active, required this.onFilter});
  final String? active;
  final void Function(String?) onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: 'All', value: null, active: active, onTap: onFilter),
        const SizedBox(width: 8),
        _Chip(
          label: 'Active',
          value: 'ACTIVE',
          active: active,
          onTap: onFilter,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Resolved',
          value: 'RESOLVED',
          active: active,
          onTap: onFilter,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });
  final String label;
  final String? value;
  final String? active;
  final void Function(String?) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = active == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBg : AppColors.darkBg3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.darkLine,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.accent : AppColors.darkFg2,
          ),
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.loading,
    required this.alerts,
    this.error,
    required this.onRetry,
  });
  final bool loading;
  final List<SosAlert> alerts;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.bad),
            const SizedBox(height: 12),
            Text(error!, style: AppTextStyles.body),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (alerts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 40, color: AppColors.good),
            SizedBox(height: 12),
            Text('No alerts found', style: AppTextStyles.body),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.darkLine),
      itemBuilder: (_, i) => _AlertRow(alert: alerts[i]),
    );
  }
}

// ── Alert row ─────────────────────────────────────────────────────────────────

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});
  final SosAlert alert;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, HH:mm');
    final created = DateTime.tryParse(alert.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: alert.isActive ? AppColors.badBg : AppColors.darkBg3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.sos_rounded,
              size: 18,
              color: alert.isActive ? AppColors.bad : AppColors.darkFg3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.triggeredByName,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.darkFg0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusTag(
                      label: alert.isActive ? 'Active' : 'Resolved',
                      color: alert.isActive ? AppColors.bad : AppColors.good,
                      bgColor: alert.isActive
                          ? AppColors.badBg
                          : AppColors.goodBg,
                    ),
                  ],
                ),
                if (alert.message != null && alert.message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    alert.message!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.darkFg2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (alert.lat != null && alert.lng != null) ...[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.darkFg3,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${alert.lat!.toStringAsFixed(4)}, ${alert.lng!.toStringAsFixed(4)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.darkFg3,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.darkFg3,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      created != null ? fmt.format(created.toLocal()) : '—',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkFg3,
                      ),
                    ),
                  ],
                ),
                if (alert.isActive) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.accentFg,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () => _showResolveDialog(context),
                      icon: const Icon(Icons.check_rounded, size: 14),
                      label: const Text('Resolve'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg2,
        title: Text(
          'Resolve SOS Alert',
          style: AppTextStyles.h3.copyWith(color: AppColors.darkFg0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Triggered by: ${alert.triggeredByName}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              style: AppTextStyles.body.copyWith(color: AppColors.darkFg0),
              decoration: InputDecoration(
                hintText: 'Resolution notes (optional)',
                hintStyle: AppTextStyles.bodySm.copyWith(
                  color: AppColors.darkFg3,
                ),
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
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkFg2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.accentFg,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SosAlertBloc>().add(
                SosAlertResolveRequested(
                  alert.id,
                  notes: notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Confirm Resolve'),
          ),
        ],
      ),
    );
  }
}

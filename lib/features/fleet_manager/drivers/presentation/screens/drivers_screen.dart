import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/dls/dls.dart';
import '../../domain/driver.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';
import '../bloc/driver_state.dart';
import 'driver_form_sheet.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  String? _filter; // null = all

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const DriverLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
      body: BlocConsumer<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state is DriverMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.good),
            );
          } else if (state is DriverMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.bad),
            );
          }
        },
        builder: (context, state) {
          final allDrivers = switch (state) {
            DriverLoaded(:final drivers) => drivers,
            DriverMutating(:final drivers) => drivers,
            DriverMutationSuccess(:final drivers) => drivers,
            DriverMutationError(:final drivers) => drivers,
            _ => <Driver>[],
          };

          final drivers = _filter == null
              ? allDrivers
              : allDrivers.where((d) => d.availability == _filter).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drivers', style: AppTextStyles.h2.copyWith(color: AppColors.darkFg0)),
                          Text('${allDrivers.length} total', style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2)),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => DriverFormSheet.show(context),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Add Driver'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _AvailabilityBar(
                    active: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                    drivers: allDrivers,
                  ),
                ),
              ),
              if (state is DriverLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state is DriverError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.bad),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.body.copyWith(color: AppColors.darkFg1), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<DriverBloc>().add(const DriverLoadRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (drivers.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 56, color: AppColors.darkFg3),
                        const SizedBox(height: 12),
                        Text(_filter != null ? 'No drivers with this status' : 'No drivers yet', style: AppTextStyles.h4.copyWith(color: AppColors.darkFg1)),
                        if (_filter == null) ...[
                          const SizedBox(height: 4),
                          Text('Add your first driver to get started', style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2)),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => DriverFormSheet.show(context),
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Add Driver'),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: drivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _DriverCard(
                      driver: drivers[i],
                      isMutating: state is DriverMutating,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AvailabilityBar extends StatelessWidget {
  final String? active;
  final ValueChanged<String?> onChanged;
  final List<Driver> drivers;

  const _AvailabilityBar({required this.active, required this.onChanged, required this.drivers});

  @override
  Widget build(BuildContext context) {
    int count(String? f) =>
        f == null ? drivers.length : drivers.where((d) => d.availability == f).length;

    final filters = [
      (label: 'All', value: null),
      (label: 'Available', value: 'AVAILABLE'),
      (label: 'On Trip', value: 'ON_TRIP'),
      (label: 'Off Duty', value: 'OFF_DUTY'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = active == f.value;
          final n = count(f.value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${f.label} ($n)'),
              selected: selected,
              onSelected: (_) => onChanged(f.value),
              selectedColor: AppColors.accentBg,
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : AppColors.darkFg2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              side: BorderSide(color: selected ? AppColors.accent : AppColors.darkLine),
              backgroundColor: AppColors.darkBg3,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final bool isMutating;

  const _DriverCard({required this.driver, required this.isMutating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Row(
        children: [
          _Avatar(initials: driver.initials, availability: driver.availability),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(driver.fullName, style: AppTextStyles.h4.copyWith(color: AppColors.darkFg0), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    _AvailabilityBadge(availability: driver.availability),
                  ],
                ),
                const SizedBox(height: 3),
                Text(driver.phone, style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2)),
                const SizedBox(height: 2),
                Text('License: ${driver.licenseNumber}', style: AppTextStyles.bodySm.copyWith(color: AppColors.darkFg2)),
                if (driver.licenseExpiry != null) ...[
                  const SizedBox(height: 4),
                  _ExpiryRow(label: 'License', date: driver.licenseExpiry!),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            enabled: !isMutating,
            onSelected: (action) {
              if (action == 'edit') DriverFormSheet.show(context, driver: driver);
              if (action == 'delete') _confirmDelete(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Remove', style: TextStyle(color: AppColors.bad)),
              ),
            ],
            child: const Icon(Icons.more_vert, color: AppColors.darkFg3),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Driver'),
        content: Text('Remove ${driver.fullName} from the fleet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DriverBloc>().add(DriverDeleteRequested(driver.id));
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.bad)),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final String availability;

  const _Avatar({required this.initials, required this.availability});

  @override
  Widget build(BuildContext context) {
    final color = switch (availability) {
      'AVAILABLE' => AppColors.good,
      'ON_TRIP' => AppColors.accent,
      _ => AppColors.darkFg3,
    };
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.12),
          child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBg2, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final String availability;
  const _AvailabilityBadge({required this.availability});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (availability) {
      'AVAILABLE' => (AppColors.good, AppColors.goodBg, 'Available'),
      'ON_TRIP' => (AppColors.accent, AppColors.accentBg, 'On Trip'),
      'OFF_DUTY' => (AppColors.darkFg3, AppColors.darkBg3, 'Off Duty'),
      _ => (AppColors.darkFg3, AppColors.darkBg3, availability),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  final String label;
  final String date;
  const _ExpiryRow({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    final expiry = DateTime.tryParse(date);
    final daysLeft = expiry?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;
    final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft < 30;
    final color = isExpired ? AppColors.bad : isExpiringSoon ? AppColors.warn : AppColors.darkFg3;

    return Row(
      children: [
        Icon(Icons.credit_card_outlined, size: 12, color: color),
        const SizedBox(width: 4),
        Text('$label expires: $date',
            style: TextStyle(fontSize: 11, color: color,
                fontWeight: isExpiringSoon || isExpired ? FontWeight.w600 : FontWeight.w400)),
        if (isExpired) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.badBg, borderRadius: BorderRadius.circular(4)),
            child: const Text('Expired', style: TextStyle(fontSize: 10, color: AppColors.bad, fontWeight: FontWeight.w600)),
          ),
        ] else if (isExpiringSoon) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.warnBg, borderRadius: BorderRadius.circular(4)),
            child: Text('$daysLeft days left',
                style: const TextStyle(fontSize: 10, color: AppColors.warn, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

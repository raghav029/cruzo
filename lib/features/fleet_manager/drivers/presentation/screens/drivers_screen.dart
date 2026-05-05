import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.background,
      body: BlocConsumer<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state is DriverMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is DriverMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
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
                          Text('Drivers', style: AppTextStyles.h2),
                          Text('${allDrivers.length} total', style: AppTextStyles.bodySm),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => DriverFormSheet.show(context),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Add Driver'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.body, textAlign: TextAlign.center),
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
                        Icon(Icons.person_outline, size: 56, color: AppColors.grey300),
                        const SizedBox(height: 12),
                        Text(_filter != null ? 'No drivers with this status' : 'No drivers yet', style: AppTextStyles.h4),
                        if (_filter == null) ...[
                          const SizedBox(height: 4),
                          Text('Add your first driver to get started', style: AppTextStyles.bodySm),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => DriverFormSheet.show(context),
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Add Driver'),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
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
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.grey600,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              side: BorderSide(color: selected ? AppColors.primary : AppColors.grey200),
              backgroundColor: AppColors.white,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
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
                      child: Text(driver.fullName, style: AppTextStyles.h4, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    _AvailabilityBadge(availability: driver.availability),
                  ],
                ),
                const SizedBox(height: 3),
                Text(driver.phone, style: AppTextStyles.bodySm),
                const SizedBox(height: 2),
                Text('License: ${driver.licenseNumber}', style: AppTextStyles.bodySm),
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
                child: Text('Remove', style: TextStyle(color: AppColors.error)),
              ),
            ],
            child: const Icon(Icons.more_vert, color: AppColors.grey400),
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
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
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
      'AVAILABLE' => AppColors.success,
      'ON_TRIP' => AppColors.primary,
      _ => AppColors.grey400,
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
              border: Border.all(color: AppColors.white, width: 2),
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
      'AVAILABLE' => (AppColors.success, AppColors.successLight, 'Available'),
      'ON_TRIP' => (AppColors.primary, AppColors.primaryLight, 'On Trip'),
      'OFF_DUTY' => (AppColors.grey500, AppColors.grey100, 'Off Duty'),
      _ => (AppColors.grey500, AppColors.grey100, availability),
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
    final color = isExpired ? AppColors.error : isExpiringSoon ? AppColors.warning : AppColors.grey400;

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
            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(4)),
            child: const Text('Expired', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ] else if (isExpiringSoon) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
            child: Text('$daysLeft days left',
                style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

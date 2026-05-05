import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/vehicle.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import 'vehicle_form_sheet.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(const VehicleLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is VehicleMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final vehicles = switch (state) {
            VehicleLoaded(:final vehicles) => vehicles,
            VehicleMutating(:final vehicles) => vehicles,
            VehicleMutationSuccess(:final vehicles) => vehicles,
            VehicleMutationError(:final vehicles) => vehicles,
            _ => <Vehicle>[],
          };

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
                          Text('Vehicles', style: AppTextStyles.h2),
                          Text('${vehicles.length} total', style: AppTextStyles.bodySm),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => VehicleFormSheet.show(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Vehicle'),
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
                  child: _FilterBar(
                    active: _activeFilter,
                    onChanged: (f) {
                      setState(() => _activeFilter = f);
                      context.read<VehicleBloc>().add(VehicleLoadRequested(statusFilter: f));
                    },
                  ),
                ),
              ),
              if (state is VehicleLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is VehicleError)
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
                          onPressed: () => context.read<VehicleBloc>().add(const VehicleLoadRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (vehicles.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 56, color: AppColors.grey300),
                        const SizedBox(height: 12),
                        Text('No vehicles yet', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text('Add your first vehicle to get started', style: AppTextStyles.bodySm),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => VehicleFormSheet.show(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Vehicle'),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _VehicleCard(
                      vehicle: vehicles[i],
                      isMutating: state is VehicleMutating,
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

class _FilterBar extends StatelessWidget {
  final String? active;
  final ValueChanged<String?> onChanged;

  const _FilterBar({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const filters = [
      (label: 'All', value: null),
      (label: 'Active', value: 'ACTIVE'),
      (label: 'In Trip', value: 'IN_TRIP'),
      (label: 'Inactive', value: 'INACTIVE'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = active == f.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.label),
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

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isMutating;

  const _VehicleCard({required this.vehicle, required this.isMutating});

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
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _typeColor(vehicle.vehicleType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(vehicle.vehicleType), color: _typeColor(vehicle.vehicleType), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${vehicle.make} ${vehicle.model}', style: AppTextStyles.h4),
                    const SizedBox(width: 8),
                    _StatusBadge(status: vehicle.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${vehicle.plateNumber}  •  ${vehicle.vehicleType}  •  ${vehicle.year}',
                  style: AppTextStyles.bodySm,
                ),
                if (vehicle.insuranceExpiry != null) ...[
                  const SizedBox(height: 4),
                  _ExpiryRow(label: 'Insurance', date: vehicle.insuranceExpiry!),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            enabled: !isMutating,
            onSelected: (action) {
              if (action == 'edit') {
                VehicleFormSheet.show(context, vehicle: vehicle);
              } else if (action == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
        title: const Text('Delete Vehicle'),
        content: Text('Remove ${vehicle.make} ${vehicle.model} (${vehicle.plateNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VehicleBloc>().add(VehicleDeleteRequested(vehicle.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) => switch (type) {
        'SEDAN' => AppColors.primary,
        'SUV' => AppColors.success,
        'LUXURY' => const Color(0xFF7C3AED),
        _ => AppColors.grey500,
      };

  IconData _typeIcon(String type) => switch (type) {
        'SEDAN' => Icons.directions_car,
        'SUV' => Icons.airport_shuttle,
        'LUXURY' => Icons.star,
        _ => Icons.directions_car_outlined,
      };
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      'ACTIVE' => (AppColors.success, AppColors.successLight, 'Active'),
      'IN_TRIP' => (AppColors.primary, AppColors.primaryLight, 'In Trip'),
      'INACTIVE' => (AppColors.grey500, AppColors.grey100, 'Inactive'),
      _ => (AppColors.grey500, AppColors.grey100, status),
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
    final isExpiringSoon = expiry != null && expiry.difference(DateTime.now()).inDays < 30;
    final isExpired = expiry != null && expiry.isBefore(DateTime.now());
    final color = isExpired ? AppColors.error : isExpiringSoon ? AppColors.warning : AppColors.grey400;

    return Row(
      children: [
        Icon(Icons.shield_outlined, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: $date',
          style: TextStyle(fontSize: 11, color: color, fontWeight: isExpiringSoon ? FontWeight.w600 : FontWeight.w400),
        ),
        if (isExpiringSoon && !isExpired) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
            child: const Text('Expiring soon', style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
          ),
        ],
        if (isExpired) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(4)),
            child: const Text('Expired', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

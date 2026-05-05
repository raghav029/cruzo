import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/corporate_client.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import 'add_admin_sheet.dart';
import 'client_form_sheet.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(const ClientLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ClientBloc, ClientState>(
        listener: (context, state) {
          if (state is ClientMutationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is ClientMutationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final all = switch (state) {
            ClientLoaded(:final clients) => clients,
            ClientMutating(:final clients) => clients,
            ClientMutationSuccess(:final clients) => clients,
            ClientMutationError(:final clients) => clients,
            _ => <CorporateClient>[],
          };

          final clients = _showInactive ? all : all.where((c) => c.active).toList();

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
                          Text('Corporate Clients', style: AppTextStyles.h2),
                          Text('${all.length} total', style: AppTextStyles.bodySm),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => ClientFormSheet.show(context),
                        icon: const Icon(Icons.business_outlined, size: 18),
                        label: const Text('Add Client'),
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      _SummaryChip(
                        label: 'Active',
                        count: all.where((c) => c.active).length,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _SummaryChip(
                        label: 'Inactive',
                        count: all.where((c) => !c.active).length,
                        color: AppColors.grey400,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text('Show inactive', style: AppTextStyles.caption),
                          const SizedBox(width: 6),
                          Switch.adaptive(
                            value: _showInactive,
                            onChanged: (v) => setState(() => _showInactive = v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (state is ClientLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state is ClientError)
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
                          onPressed: () => context.read<ClientBloc>().add(const ClientLoadRequested()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (clients.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business_outlined, size: 56, color: AppColors.grey300),
                        const SizedBox(height: 12),
                        Text('No clients yet', style: AppTextStyles.h4),
                        const SizedBox(height: 4),
                        Text('Add your first corporate client to get started', style: AppTextStyles.bodySm),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => ClientFormSheet.show(context),
                          icon: const Icon(Icons.business_outlined),
                          label: const Text('Add Client'),
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
                    itemCount: clients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ClientCard(
                      client: clients[i],
                      isMutating: state is ClientMutating,
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

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$count $label',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final CorporateClient client;
  final bool isMutating;

  const _ClientCard({required this.client, required this.isMutating});

  @override
  Widget build(BuildContext context) {
    final utilizationColor = client.utilizationPct > 0.9
        ? AppColors.error
        : client.utilizationPct > 0.7
            ? AppColors.warning
            : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: client.active ? AppColors.grey200 : AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: client.active ? AppColors.primaryLight : AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    client.companyName.isNotEmpty ? client.companyName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: client.active ? AppColors.primary : AppColors.grey400,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(client.companyName,
                                style: AppTextStyles.h4, overflow: TextOverflow.ellipsis),
                          ),
                          if (!client.active) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.grey100, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Inactive',
                                  style: TextStyle(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(client.billingEmail, style: AppTextStyles.bodySm),
                      if (client.gstNumber != null) ...[
                        const SizedBox(height: 1),
                        Text('GST: ${client.gstNumber}', style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !isMutating,
                  onSelected: (action) {
                    if (action == 'edit') ClientFormSheet.show(context, client: client);
                    if (action == 'admin') {
                      AddAdminSheet.show(context,
                          clientId: client.id, companyName: client.companyName);
                    }
                    if (action == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'admin',
                      child: Row(children: [
                        Icon(Icons.person_add_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Add Admin'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, color: AppColors.grey400),
                ),
              ],
            ),
          ),
          if (client.creditLimit > 0) ...[
            Divider(height: 1, color: AppColors.grey100),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CreditStat(
                        label: 'Credit Limit',
                        value: '₹${_fmt(client.creditLimit)}',
                        color: AppColors.grey700,
                      ),
                      _CreditStat(
                        label: 'Outstanding',
                        value: '₹${_fmt(client.currentOutstanding)}',
                        color: client.currentOutstanding > 0 ? AppColors.warning : AppColors.grey500,
                      ),
                      _CreditStat(
                        label: 'Available',
                        value: '₹${_fmt(client.availableCredit)}',
                        color: utilizationColor,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: utilizationColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(client.utilizationPct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: utilizationColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: client.utilizationPct,
                      backgroundColor: AppColors.grey100,
                      valueColor: AlwaysStoppedAnimation(utilizationColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.refresh_outlined, size: 13, color: AppColors.grey400),
                const SizedBox(width: 4),
                Text(
                  '${client.billingCycle == 'MONTHLY' ? 'Monthly' : 'Weekly'} billing',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Remove ${client.companyName}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ClientBloc>().add(ClientDeleteRequested(client.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _CreditStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CreditStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

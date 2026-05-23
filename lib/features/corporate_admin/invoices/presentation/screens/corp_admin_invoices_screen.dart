import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../fleet_manager/invoices/domain/invoice.dart';
import '../../../../fleet_manager/invoices/presentation/bloc/invoice_bloc.dart';
import '../../../../fleet_manager/invoices/presentation/bloc/invoice_event.dart';
import '../../../../fleet_manager/invoices/presentation/bloc/invoice_state.dart';
import '../../../../../../shared/widgets/cruzo_card.dart';
import '../../../../../../shared/widgets/avatar_widget.dart';
import '../../../../../../shared/widgets/status_tag.dart';
import '../../../../../../core/theme/dls/dls.dart';

final _inrFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class CorpAdminInvoicesScreen extends StatefulWidget {
  const CorpAdminInvoicesScreen({super.key});

  @override
  State<CorpAdminInvoicesScreen> createState() =>
      _CorpAdminInvoicesScreenState();
}

class _CorpAdminInvoicesScreenState extends State<CorpAdminInvoicesScreen> {
  final _search = TextEditingController();
  Invoice? _selected;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(const InvoiceLoadRequested());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (ctx, state) {
        final invoices = _invoicesFrom(state);
        final loading = state is InvoiceLoading;

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: _CorpAdminHeader(),
                  ),
                ),
                if (!loading && invoices.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: _CorpAdminKpiRow(invoices: invoices),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: CruzoCard(
                      title: 'All invoices',
                      subtitle: loading ? null : '${invoices.length} total',
                      action: SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _search,
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(
                            hintText: 'Search invoices…',
                            prefixIcon: Icon(Icons.search, size: 16),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      flush: true,
                      child: _body(loading, invoices, state),
                    ),
                  ),
                ),
              ],
            ),
            if (_selected != null)
              _CorpAdminDetailDrawer(
                inv: _selected!,
                onClose: () => setState(() => _selected = null),
              ),
          ],
        );
      },
    );
  }

  Widget _body(bool loading, List<Invoice> invoices, InvoiceState state) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is InvoiceError) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Text(state.message, style: AppTextStyles.body),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context
                    .read<InvoiceBloc>()
                    .add(const InvoiceLoadRequested()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final filtered = _filter(invoices);
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No invoices found')),
      );
    }
    return _CorpAdminInvoiceTable(
      invoices: filtered,
      onTap: (inv) => setState(() => _selected = inv),
    );
  }

  List<Invoice> _invoicesFrom(InvoiceState state) {
    if (state is InvoiceLoaded) return state.invoices;
    if (state is InvoiceMutating) return state.invoices;
    if (state is InvoiceMutationSuccess) return state.invoices;
    if (state is InvoiceMutationError) return state.invoices;
    return [];
  }

  List<Invoice> _filter(List<Invoice> all) {
    final q = _search.text.toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((i) =>
            i.invoiceNumber.toLowerCase().contains(q) ||
            i.corporateClientName.toLowerCase().contains(q) ||
            i.period.toLowerCase().contains(q))
        .toList();
  }
}

// ── Header (read-only, no generate button) ────────────────────────────────────

class _CorpAdminHeader extends StatelessWidget {
  const _CorpAdminHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoices', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Invoice history for your organisation',
            style: AppTextStyles.bodySm),
      ],
    );
  }
}

// ── KPI row ───────────────────────────────────────────────────────────────────

class _CorpAdminKpiRow extends StatelessWidget {
  const _CorpAdminKpiRow({required this.invoices});

  final List<Invoice> invoices;

  @override
  Widget build(BuildContext context) {
    final outstanding = invoices.where((i) => i.isSent);
    final paid = invoices.where((i) => i.isPaid);
    final overdue = invoices.where((i) => i.isOverdue);
    final drafts = invoices.where((i) => i.isDraft);

    double sum(Iterable<Invoice> list) =>
        list.fold(0, (s, i) => s + i.totalAmount);

    final kpis = [
      (
        'Outstanding',
        _inrFmt.format(sum(outstanding)),
        '${outstanding.length} invoices',
        AppColors.warn,
        false
      ),
      (
        'Paid this month',
        _inrFmt.format(sum(paid)),
        '${paid.length} invoices',
        AppColors.good,
        false
      ),
      (
        'Overdue',
        _inrFmt.format(sum(overdue)),
        '${overdue.length} invoice${overdue.length == 1 ? '' : 's'}',
        AppColors.bad,
        true
      ),
      (
        'Drafts',
        _inrFmt.format(sum(drafts)),
        '${drafts.length} invoice${drafts.length == 1 ? '' : 's'}',
        AppColors.darkFg3,
        false
      ),
    ];

    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth > 700 ? 4 : 2;
      final w = (c.maxWidth - 12.0 * (cols - 1)) / cols;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: kpis.map((k) {
          return SizedBox(
            width: w,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBg2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(k.$1, style: AppTextStyles.kpiLabel),
                  const SizedBox(height: 8),
                  Text(k.$2,
                      style: AppTextStyles.kpiValue
                          .copyWith(color: k.$5 ? k.$4 : AppColors.darkFg0)),
                  const SizedBox(height: 4),
                  Text(k.$3, style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ── Table ─────────────────────────────────────────────────────────────────────

class _CorpAdminInvoiceTable extends StatelessWidget {
  const _CorpAdminInvoiceTable(
      {required this.invoices, required this.onTap});

  final List<Invoice> invoices;
  final ValueChanged<Invoice> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CorpAdminTableHeader(),
        const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
        ...invoices
            .map((inv) => _CorpAdminTableRow(inv: inv, onTap: () => onTap(inv))),
      ],
    );
  }
}

class _CorpAdminTableHeader extends StatelessWidget {
  const _CorpAdminTableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          _Th('Invoice', flex: 2),
          _Th('Client', flex: 3),
          _Th('Period', flex: 3),
          _Th('Amount', flex: 2, align: TextAlign.right),
          _Th('Issued', flex: 2),
          _Th('Status', flex: 2),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _CorpAdminTableRow extends StatefulWidget {
  const _CorpAdminTableRow({required this.inv, required this.onTap});

  final Invoice inv;
  final VoidCallback onTap;

  @override
  State<_CorpAdminTableRow> createState() => _CorpAdminTableRowState();
}

class _CorpAdminTableRowState extends State<_CorpAdminTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.inv;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hovered ? AppColors.darkBg3 : Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(inv.invoiceNumber,
                          style: AppTextStyles.mono
                              .copyWith(color: AppColors.accent)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          AvatarWidget(
                              name: inv.corporateClientName, radius: 12),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(inv.corporateClientName,
                                style: AppTextStyles.tableCell,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(inv.period,
                          style: AppTextStyles.tableCell
                              .copyWith(color: AppColors.darkFg2)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                          _inrFmt.format(inv.totalAmount),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.mono
                              .copyWith(color: AppColors.darkFg0)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                          inv.createdAt.substring(0, 10),
                          style: AppTextStyles.tableCell
                              .copyWith(color: AppColors.darkFg3)),
                    ),
                    Expanded(
                      flex: 2,
                      child: _CorpAdminStatusTag(status: inv.status),
                    ),
                    const SizedBox(
                      width: 24,
                      child: Icon(Icons.chevron_right,
                          size: 14, color: AppColors.darkFg3),
                    ),
                  ],
                ),
              ),
              const Divider(
                  height: 1, thickness: 1, color: AppColors.darkLine),
            ],
          ),
        ),
      ),
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.label, {this.flex = 1, this.align = TextAlign.left});

  final String label;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child:
          Text(label, textAlign: align, style: AppTextStyles.tableHeader),
    );
  }
}

// ── Status tag ────────────────────────────────────────────────────────────────

class _CorpAdminStatusTag extends StatelessWidget {
  const _CorpAdminStatusTag({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'PAID' => (AppColors.good, AppColors.goodBg),
      'SENT' => (AppColors.info, AppColors.infoBg),
      'OVERDUE' => (AppColors.bad, AppColors.badBg),
      'DRAFT' => (AppColors.darkFg3, AppColors.darkBg3),
      _ => (AppColors.darkFg2, AppColors.darkBg3),
    };
    return StatusTag(label: status, color: color, bgColor: bg);
  }
}

// ── Detail drawer (read-only, no action buttons) ──────────────────────────────

class _CorpAdminDetailDrawer extends StatelessWidget {
  const _CorpAdminDetailDrawer({
    required this.inv,
    required this.onClose,
  });

  final Invoice inv;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 420,
              height: double.infinity,
              color: AppColors.darkBg2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CorpAdminDrawerHead(inv: inv, onClose: onClose),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.darkLine),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _CorpAdminDrawerBody(inv: inv),
                    ),
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.darkLine),
                  _CorpAdminDrawerFoot(inv: inv, onClose: onClose),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CorpAdminDrawerHead extends StatelessWidget {
  const _CorpAdminDrawerHead({required this.inv, required this.onClose});

  final Invoice inv;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.invoiceNumber,
                    style: AppTextStyles.monoSm
                        .copyWith(color: AppColors.darkFg3)),
                const SizedBox(height: 2),
                Text(inv.corporateClientName, style: AppTextStyles.h3),
              ],
            ),
          ),
          _CorpAdminStatusTag(status: inv.status),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}

class _CorpAdminDrawerBody extends StatelessWidget {
  const _CorpAdminDrawerBody({required this.inv});

  final Invoice inv;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Stat('Period', inv.period),
            _Stat('Total', _inrFmt.format(inv.totalAmount)),
            _Stat('Subtotal', _inrFmt.format(inv.subtotal)),
            _Stat('CGST', _inrFmt.format(inv.cgstAmount)),
            _Stat('SGST', _inrFmt.format(inv.sgstAmount)),
            if (inv.dueDate != null) _Stat('Due', inv.dueDate!),
            if (inv.paidAt != null)
              _Stat('Paid at', inv.paidAt!.substring(0, 10)),
            if (inv.paymentMode != null)
              _Stat('Payment', inv.paymentMode!),
          ],
        ),
        if (inv.notes != null && inv.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Notes', style: AppTextStyles.kpiLabel),
          const SizedBox(height: 6),
          Text(inv.notes!, style: AppTextStyles.body),
        ],
        if (inv.lineItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Line items', style: AppTextStyles.kpiLabel),
          const SizedBox(height: 10),
          ...inv.lineItems.take(6).map((li) => _LineItemRow(li: li)),
          if (inv.lineItems.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '… and ${inv.lineItems.length - 6} more',
                style: AppTextStyles.caption,
              ),
            ),
        ],
      ],
    );
  }
}

// ── Drawer footer — totals only, no action buttons ────────────────────────────

class _CorpAdminDrawerFoot extends StatelessWidget {
  const _CorpAdminDrawerFoot({required this.inv, required this.onClose});

  final Invoice inv;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total', style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(_inrFmt.format(inv.totalAmount),
                  style: AppTextStyles.h3),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: onClose,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h4),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.li});

  final InvoiceLineItem li;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkBg3,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(li.description, style: AppTextStyles.body),
                if (li.tripDate != null)
                  Text(li.tripDate!, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(_inrFmt.format(li.lineTotal),
              style: AppTextStyles.mono.copyWith(color: AppColors.darkFg0)),
        ],
      ),
    );
  }
}

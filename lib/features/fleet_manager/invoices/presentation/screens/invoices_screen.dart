import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/invoice.dart';
import '../bloc/invoice_bloc.dart';
import '../bloc/invoice_event.dart';
import '../bloc/invoice_state.dart';
import '../../../../../shared/widgets/cruzo_card.dart';
import '../../../../../shared/widgets/avatar_widget.dart';
import '../../../../../shared/widgets/status_tag.dart';
import '../../../../../core/theme/dls/dls.dart';

final _inrFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
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
    return BlocConsumer<InvoiceBloc, InvoiceState>(
      listener: (ctx, state) {
        if (state is InvoiceMutationSuccess) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is InvoiceMutationError) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
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
                    child: _Header(
                      onGenerate: () => _showGenerate(ctx),
                    ),
                  ),
                ),
                if (!loading && invoices.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: _KpiRow(invoices: invoices),
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
              _DetailDrawer(
                inv: _selected!,
                onClose: () => setState(() => _selected = null),
                onMarkSent: (id) {
                  ctx.read<InvoiceBloc>().add(InvoiceMarkSentRequested(id));
                  setState(() => _selected = null);
                },
                onMarkPaid: (id) {
                  ctx.read<InvoiceBloc>().add(InvoiceMarkPaidRequested(id));
                  setState(() => _selected = null);
                },
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
    return _InvoiceTable(
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

  void _showGenerate(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => BlocProvider.value(
        value: ctx.read<InvoiceBloc>(),
        child: const _GenerateDialog(),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoices', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text('Generated per corporate client per period',
                  style: AppTextStyles.bodySm),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Generate invoice'),
        ),
      ],
    );
  }
}

// ── KPI row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.invoices});

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
                      style: AppTextStyles.kpiValue.copyWith(
                          color:
                              k.$5 ? k.$4 : AppColors.darkFg0)),
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

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable({required this.invoices, required this.onTap});

  final List<Invoice> invoices;
  final ValueChanged<Invoice> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TableHeader(),
        const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
        ...invoices.map((inv) => _TableRow(inv: inv, onTap: () => onTap(inv))),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

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

class _TableRow extends StatefulWidget {
  const _TableRow({required this.inv, required this.onTap});

  final Invoice inv;
  final VoidCallback onTap;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                      child: _StatusTag(status: inv.status),
                    ),
                    const SizedBox(
                      width: 24,
                      child: Icon(Icons.chevron_right,
                          size: 14, color: AppColors.darkFg3),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
            ],
          ),
        ),
      ),
    );
  }
}

class _Th extends StatelessWidget {
  const _Th(this.label,
      {this.flex = 1, this.align = TextAlign.left});

  final String label;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label,
          textAlign: align, style: AppTextStyles.tableHeader),
    );
  }
}

// ── Status tag ────────────────────────────────────────────────────────────────

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

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

// ── Detail drawer ─────────────────────────────────────────────────────────────

class _DetailDrawer extends StatelessWidget {
  const _DetailDrawer({
    required this.inv,
    required this.onClose,
    required this.onMarkSent,
    required this.onMarkPaid,
  });

  final Invoice inv;
  final VoidCallback onClose;
  final ValueChanged<String> onMarkSent;
  final ValueChanged<String> onMarkPaid;

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
                  _DrawerHead(inv: inv, onClose: onClose),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.darkLine),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _DrawerBody(inv: inv),
                    ),
                  ),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.darkLine),
                  _DrawerFoot(
                    inv: inv,
                    onClose: onClose,
                    onMarkSent: onMarkSent,
                    onMarkPaid: onMarkPaid,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerHead extends StatelessWidget {
  const _DrawerHead({required this.inv, required this.onClose});

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
                    style:
                        AppTextStyles.monoSm.copyWith(color: AppColors.darkFg3)),
                const SizedBox(height: 2),
                Text(inv.corporateClientName, style: AppTextStyles.h3),
              ],
            ),
          ),
          _StatusTag(status: inv.status),
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

class _DrawerBody extends StatelessWidget {
  const _DrawerBody({required this.inv});

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
              style: AppTextStyles.mono
                  .copyWith(color: AppColors.darkFg0)),
        ],
      ),
    );
  }
}

class _DrawerFoot extends StatelessWidget {
  const _DrawerFoot({
    required this.inv,
    required this.onClose,
    required this.onMarkSent,
    required this.onMarkPaid,
  });

  final Invoice inv;
  final VoidCallback onClose;
  final ValueChanged<String> onMarkSent;
  final ValueChanged<String> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          OutlinedButton(onPressed: onClose, child: const Text('Close')),
          const Spacer(),
          if (inv.isDraft)
            ElevatedButton.icon(
              onPressed: () => onMarkSent(inv.id),
              icon: const Icon(Icons.send_outlined, size: 13),
              label: const Text('Send to client'),
            ),
          if (inv.isSent)
            ElevatedButton.icon(
              onPressed: () => onMarkPaid(inv.id),
              icon: const Icon(Icons.check, size: 13),
              label: const Text('Mark paid'),
            ),
        ],
      ),
    );
  }
}

// ── Generate dialog ───────────────────────────────────────────────────────────

class _GenerateDialog extends StatefulWidget {
  const _GenerateDialog();

  @override
  State<_GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<_GenerateDialog> {
  final _clientCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
  DateTime _to = DateTime(DateTime.now().year, DateTime.now().month, 0);
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _clientCtrl.dispose();
    _clientIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Generate invoice', style: AppTextStyles.h3),
                        const SizedBox(height: 2),
                        Text(
                          'Snapshots fares at generation time.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CLIENT ID', style: AppTextStyles.kpiLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _clientIdCtrl,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Paste corporate client UUID…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('BILLING PERIOD', style: AppTextStyles.kpiLabel),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePicker(
                          label: 'From',
                          value: _from,
                          onPick: (d) => setState(() => _from = d),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DatePicker(
                          label: 'To',
                          value: _to,
                          onPick: (d) => setState(() => _to = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('NOTES (optional)', style: AppTextStyles.kpiLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesCtrl,
                    style: AppTextStyles.body,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Internal notes…',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.darkLine),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final clientId = _clientIdCtrl.text.trim();
    if (clientId.isEmpty) return;
    setState(() => _loading = true);
    context.read<InvoiceBloc>().add(InvoiceGenerateRequested(
          corporateClientId: clientId,
          billingPeriodStart: _fmt(_from),
          billingPeriodEnd: _fmt(_to),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ));
    Navigator.pop(context);
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker(
      {required this.label, required this.value, required this.onPick});

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkBg3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkLine),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: AppColors.darkFg3),
            const SizedBox(width: 8),
            Text(fmt.format(value), style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

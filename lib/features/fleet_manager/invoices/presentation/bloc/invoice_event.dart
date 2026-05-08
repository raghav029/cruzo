abstract class InvoiceEvent {
  const InvoiceEvent();
}

class InvoiceLoadRequested extends InvoiceEvent {
  final String? clientFilter;
  const InvoiceLoadRequested({this.clientFilter});
}

class InvoiceGenerateRequested extends InvoiceEvent {
  final String corporateClientId;
  final String billingPeriodStart;
  final String billingPeriodEnd;
  final String? dueDate;
  final String? notes;

  const InvoiceGenerateRequested({
    required this.corporateClientId,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    this.dueDate,
    this.notes,
  });
}

class InvoiceMarkSentRequested extends InvoiceEvent {
  final String invoiceId;
  const InvoiceMarkSentRequested(this.invoiceId);
}

class InvoiceMarkPaidRequested extends InvoiceEvent {
  final String invoiceId;
  final String? paymentMode;
  final String? paymentReference;
  const InvoiceMarkPaidRequested(this.invoiceId,
      {this.paymentMode, this.paymentReference});
}

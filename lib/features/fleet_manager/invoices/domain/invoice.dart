class InvoiceLineItem {
  final String id;
  final String? bookingId;
  final String description;
  final String? tripDate;
  final String? vehicleType;
  final double baseFare;
  final double cgstAmount;
  final double sgstAmount;
  final double lineTotal;

  const InvoiceLineItem({
    required this.id,
    this.bookingId,
    required this.description,
    this.tripDate,
    this.vehicleType,
    required this.baseFare,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.lineTotal,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> j) => InvoiceLineItem(
        id: j['id'] as String,
        bookingId: j['bookingId'] as String?,
        description: j['description'] as String,
        tripDate: j['tripDate'] as String?,
        vehicleType: j['vehicleType'] as String?,
        baseFare: (j['baseFare'] as num).toDouble(),
        cgstAmount: (j['cgstAmount'] as num).toDouble(),
        sgstAmount: (j['sgstAmount'] as num).toDouble(),
        lineTotal: (j['lineTotal'] as num).toDouble(),
      );
}

class Invoice {
  final String id;
  final String corporateClientId;
  final String corporateClientName;
  final String invoiceNumber;
  final String billingPeriodStart;
  final String billingPeriodEnd;
  final double subtotal;
  final double cgstAmount;
  final double sgstAmount;
  final double cancellationFees;
  final double totalAmount;
  final String status;
  final String? dueDate;
  final String? sentAt;
  final String? paidAt;
  final String? paymentMode;
  final String? paymentReference;
  final String? notes;
  final List<InvoiceLineItem> lineItems;
  final String createdAt;

  const Invoice({
    required this.id,
    required this.corporateClientId,
    required this.corporateClientName,
    required this.invoiceNumber,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    required this.subtotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.cancellationFees,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.sentAt,
    this.paidAt,
    this.paymentMode,
    this.paymentReference,
    this.notes,
    required this.lineItems,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: j['id'] as String,
        corporateClientId: j['corporateClientId'] as String,
        corporateClientName: j['corporateClientName'] as String,
        invoiceNumber: j['invoiceNumber'] as String,
        billingPeriodStart: j['billingPeriodStart'] as String,
        billingPeriodEnd: j['billingPeriodEnd'] as String,
        subtotal: (j['subtotal'] as num).toDouble(),
        cgstAmount: (j['cgstAmount'] as num).toDouble(),
        sgstAmount: (j['sgstAmount'] as num).toDouble(),
        cancellationFees: (j['cancellationFees'] as num? ?? 0).toDouble(),
        totalAmount: (j['totalAmount'] as num).toDouble(),
        status: j['status'] as String,
        dueDate: j['dueDate'] as String?,
        sentAt: j['sentAt'] as String?,
        paidAt: j['paidAt'] as String?,
        paymentMode: j['paymentMode'] as String?,
        paymentReference: j['paymentReference'] as String?,
        notes: j['notes'] as String?,
        lineItems: (j['lineItems'] as List? ?? [])
            .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: j['createdAt'] as String,
      );

  bool get isDraft => status == 'DRAFT';
  bool get isSent => status == 'SENT';
  bool get isPaid => status == 'PAID';
  bool get isOverdue => status == 'OVERDUE';

  String get period => '$billingPeriodStart → $billingPeriodEnd';
}

class CorporateClient {
  final String id;
  final String companyName;
  final String? gstNumber;
  final String? billingAddress;
  final String billingEmail;
  final String billingCycle;
  final double creditLimit;
  final double currentOutstanding;
  final bool active;

  const CorporateClient({
    required this.id,
    required this.companyName,
    this.gstNumber,
    this.billingAddress,
    required this.billingEmail,
    required this.billingCycle,
    required this.creditLimit,
    required this.currentOutstanding,
    required this.active,
  });

  factory CorporateClient.fromJson(Map<String, dynamic> json) => CorporateClient(
        id: json['id'] as String,
        companyName: json['companyName'] as String,
        gstNumber: json['gstNumber'] as String?,
        billingAddress: json['billingAddress'] as String?,
        billingEmail: json['billingEmail'] as String,
        billingCycle: json['billingCycle'] as String,
        creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0,
        currentOutstanding: (json['currentOutstanding'] as num?)?.toDouble() ?? 0,
        active: json['active'] as bool? ?? true,
      );

  double get availableCredit => creditLimit - currentOutstanding;
  double get utilizationPct => creditLimit > 0 ? (currentOutstanding / creditLimit).clamp(0, 1) : 0;
}

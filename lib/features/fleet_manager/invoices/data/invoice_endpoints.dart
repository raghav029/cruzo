class InvoiceEndpoints {
  static const String base = '/api/invoices';
  static const String generate = '$base/generate';

  static String byId(String id) => '$base/$id';
  static String markSent(String id) => '$base/$id/mark-sent';
  static String markPaid(String id) => '$base/$id/mark-paid';
}

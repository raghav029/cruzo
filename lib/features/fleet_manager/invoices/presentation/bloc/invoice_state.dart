import '../../domain/invoice.dart';

abstract class InvoiceState {
  const InvoiceState();
}

class InvoiceInitial extends InvoiceState {}
class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> invoices;
  final String? clientFilter;
  const InvoiceLoaded(this.invoices, {this.clientFilter});
}

class InvoiceError extends InvoiceState {
  final String message;
  const InvoiceError(this.message);
}

class InvoiceMutating extends InvoiceState {
  final List<Invoice> invoices;
  const InvoiceMutating(this.invoices);
}

class InvoiceMutationSuccess extends InvoiceState {
  final List<Invoice> invoices;
  final String message;
  const InvoiceMutationSuccess(this.invoices, this.message);
}

class InvoiceMutationError extends InvoiceState {
  final List<Invoice> invoices;
  final String message;
  const InvoiceMutationError(this.invoices, this.message);
}

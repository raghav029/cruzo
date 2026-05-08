import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/invoice.dart';
import '../../domain/invoice_repo.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepo _repo;

  InvoiceBloc(this._repo) : super(InvoiceInitial()) {
    on<InvoiceLoadRequested>(_onLoad);
    on<InvoiceGenerateRequested>(_onGenerate);
    on<InvoiceMarkSentRequested>(_onMarkSent);
    on<InvoiceMarkPaidRequested>(_onMarkPaid);
  }

  Future<void> _onLoad(
    InvoiceLoadRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    final result = await _repo.list(corporateClientId: event.clientFilter);
    switch (result) {
      case Success(:final value):
        emit(InvoiceLoaded(value, clientFilter: event.clientFilter));
      case Failure(:final message):
        emit(InvoiceError(message));
    }
  }

  Future<void> _onGenerate(
    InvoiceGenerateRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    final current = _current();
    emit(InvoiceMutating(current));
    final result = await _repo.generate(
      corporateClientId: event.corporateClientId,
      billingPeriodStart: event.billingPeriodStart,
      billingPeriodEnd: event.billingPeriodEnd,
      dueDate: event.dueDate,
      notes: event.notes,
    );
    _handleMutation(emit, result, current, 'Invoice generated');
  }

  Future<void> _onMarkSent(
    InvoiceMarkSentRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    final current = _current();
    emit(InvoiceMutating(current));
    final result = await _repo.markSent(event.invoiceId);
    _handleMutation(emit, result, current, 'Invoice marked as sent');
  }

  Future<void> _onMarkPaid(
    InvoiceMarkPaidRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    final current = _current();
    emit(InvoiceMutating(current));
    final result = await _repo.markPaid(
      event.invoiceId,
      paymentMode: event.paymentMode,
      paymentReference: event.paymentReference,
    );
    _handleMutation(emit, result, current, 'Invoice marked as paid');
  }

  List<Invoice> _current() {
    final s = state;
    if (s is InvoiceLoaded) return s.invoices;
    if (s is InvoiceMutating) return s.invoices;
    if (s is InvoiceMutationSuccess) return s.invoices;
    if (s is InvoiceMutationError) return s.invoices;
    return [];
  }

  void _handleMutation(
    Emitter<InvoiceState> emit,
    ApiResult<Invoice> result,
    List<Invoice> current,
    String successMsg,
  ) {
    switch (result) {
      case Success(:final value):
        final updated = [
          ...current.map((i) => i.id == value.id ? value : i),
          if (!current.any((i) => i.id == value.id)) value,
        ];
        emit(InvoiceMutationSuccess(updated, successMsg));
      case Failure(:final message):
        emit(InvoiceMutationError(current, message));
    }
  }
}

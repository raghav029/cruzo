import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/report_repo.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepo _repo;

  ReportBloc(this._repo) : super(ReportInitial()) {
    on<FleetSummaryRequested>(_onFleetSummary);
    on<CorporateSpendRequested>(_onCorporateSpend);
  }

  Future<void> _onFleetSummary(
    FleetSummaryRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await _repo.fleetSummary(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    switch (result) {
      case Success(:final value):
        emit(FleetSummaryLoaded(value,
            fromDate: event.fromDate, toDate: event.toDate));
      case Failure(:final message):
        emit(ReportError(message));
    }
  }

  Future<void> _onCorporateSpend(
    CorporateSpendRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await _repo.corporateSpend(
      corporateClientId: event.corporateClientId,
      fromDate: event.fromDate,
      toDate: event.toDate,
    );
    switch (result) {
      case Success(:final value):
        emit(CorporateSpendLoaded(value,
            corporateClientId: event.corporateClientId,
            fromDate: event.fromDate,
            toDate: event.toDate));
      case Failure(:final message):
        emit(ReportError(message));
    }
  }
}

import '../../domain/report_models.dart';

abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class FleetSummaryLoaded extends ReportState {
  final FleetSummary summary;
  final String? fromDate;
  final String? toDate;
  const FleetSummaryLoaded(this.summary, {this.fromDate, this.toDate});
}

class CorporateSpendLoaded extends ReportState {
  final CorporateSpend spend;
  final String corporateClientId;
  final String? fromDate;
  final String? toDate;
  const CorporateSpendLoaded(
    this.spend, {
    required this.corporateClientId,
    this.fromDate,
    this.toDate,
  });
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
}

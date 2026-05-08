abstract class ReportEvent {
  const ReportEvent();
}

class FleetSummaryRequested extends ReportEvent {
  final String? fromDate;
  final String? toDate;
  const FleetSummaryRequested({this.fromDate, this.toDate});
}

class CorporateSpendRequested extends ReportEvent {
  final String corporateClientId;
  final String? fromDate;
  final String? toDate;
  const CorporateSpendRequested({
    required this.corporateClientId,
    this.fromDate,
    this.toDate,
  });
}

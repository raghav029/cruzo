abstract class SosAlertEvent {
  const SosAlertEvent();
}

class SosAlertLoadRequested extends SosAlertEvent {
  final String? statusFilter;
  const SosAlertLoadRequested({this.statusFilter});
}

class SosAlertResolveRequested extends SosAlertEvent {
  final String id;
  final String? notes;
  const SosAlertResolveRequested(this.id, {this.notes});
}

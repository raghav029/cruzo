abstract class VehicleEvent {
  const VehicleEvent();
}

class VehicleLoadRequested extends VehicleEvent {
  final String? statusFilter;
  const VehicleLoadRequested({this.statusFilter});
}

class VehicleCreateRequested extends VehicleEvent {
  final Map<String, dynamic> data;
  const VehicleCreateRequested(this.data);
}

class VehicleUpdateRequested extends VehicleEvent {
  final String id;
  final Map<String, dynamic> data;
  const VehicleUpdateRequested(this.id, this.data);
}

class VehicleDeleteRequested extends VehicleEvent {
  final String id;
  const VehicleDeleteRequested(this.id);
}

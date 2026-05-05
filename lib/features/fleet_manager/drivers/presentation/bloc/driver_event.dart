abstract class DriverEvent {
  const DriverEvent();
}

class DriverLoadRequested extends DriverEvent {
  const DriverLoadRequested();
}

class DriverCreateRequested extends DriverEvent {
  final Map<String, dynamic> data;
  const DriverCreateRequested(this.data);
}

class DriverUpdateRequested extends DriverEvent {
  final String id;
  final Map<String, dynamic> data;
  const DriverUpdateRequested(this.id, this.data);
}

class DriverDeleteRequested extends DriverEvent {
  final String id;
  const DriverDeleteRequested(this.id);
}

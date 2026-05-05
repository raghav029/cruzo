abstract class ClientEvent {
  const ClientEvent();
}

class ClientLoadRequested extends ClientEvent {
  const ClientLoadRequested();
}

class ClientCreateRequested extends ClientEvent {
  final Map<String, dynamic> data;
  const ClientCreateRequested(this.data);
}

class ClientUpdateRequested extends ClientEvent {
  final String id;
  final Map<String, dynamic> data;
  const ClientUpdateRequested(this.id, this.data);
}

class ClientDeleteRequested extends ClientEvent {
  final String id;
  const ClientDeleteRequested(this.id);
}

class ClientAdminCreateRequested extends ClientEvent {
  final String clientId;
  final Map<String, dynamic> data;
  const ClientAdminCreateRequested(this.clientId, this.data);
}

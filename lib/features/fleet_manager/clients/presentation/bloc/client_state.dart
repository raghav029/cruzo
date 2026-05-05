import '../../domain/corporate_client.dart';

abstract class ClientState {
  const ClientState();
}

class ClientInitial extends ClientState {}
class ClientLoading extends ClientState {}

class ClientLoaded extends ClientState {
  final List<CorporateClient> clients;
  const ClientLoaded(this.clients);
}

class ClientError extends ClientState {
  final String message;
  const ClientError(this.message);
}

class ClientMutating extends ClientState {
  final List<CorporateClient> clients;
  const ClientMutating(this.clients);
}

class ClientMutationSuccess extends ClientState {
  final List<CorporateClient> clients;
  final String message;
  const ClientMutationSuccess(this.clients, this.message);
}

class ClientMutationError extends ClientState {
  final List<CorporateClient> clients;
  final String message;
  const ClientMutationError(this.clients, this.message);
}

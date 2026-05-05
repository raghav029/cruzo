import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/client_repo.dart';
import '../../domain/corporate_client.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepo _repo;

  ClientBloc(this._repo) : super(ClientInitial()) {
    on<ClientLoadRequested>(_onLoad);
    on<ClientCreateRequested>(_onCreate);
    on<ClientUpdateRequested>(_onUpdate);
    on<ClientDeleteRequested>(_onDelete);
    on<ClientAdminCreateRequested>(_onAdminCreate);
  }

  Future<void> _onLoad(ClientLoadRequested _, Emitter<ClientState> emit) async {
    emit(ClientLoading());
    final result = await _repo.list();
    switch (result) {
      case Success(:final value):
        emit(ClientLoaded(value));
      case Failure(:final message):
        emit(ClientError(message));
    }
  }

  Future<void> _onCreate(
    ClientCreateRequested event,
    Emitter<ClientState> emit,
  ) async {
    final current = _current();
    emit(ClientMutating(current));
    final result = await _repo.create(event.data);
    switch (result) {
      case Success(:final value):
        emit(
          ClientMutationSuccess([
            value,
            ...current,
          ], 'Client added successfully'),
        );
      case Failure(:final message):
        emit(ClientMutationError(current, message));
    }
  }

  Future<void> _onUpdate(
    ClientUpdateRequested event,
    Emitter<ClientState> emit,
  ) async {
    final current = _current();
    emit(ClientMutating(current));
    final result = await _repo.update(event.id, event.data);
    switch (result) {
      case Success(:final value):
        final updated = current
            .map((c) => c.id == event.id ? value : c)
            .toList();
        emit(ClientMutationSuccess(updated, 'Client updated successfully'));
      case Failure(:final message):
        emit(ClientMutationError(current, message));
    }
  }

  Future<void> _onDelete(
    ClientDeleteRequested event,
    Emitter<ClientState> emit,
  ) async {
    final current = _current();
    emit(ClientMutating(current));
    final result = await _repo.delete(event.id);
    switch (result) {
      case Success():
        emit(
          ClientMutationSuccess(
            current.where((c) => c.id != event.id).toList(),
            'Client removed',
          ),
        );
      case Failure(:final message):
        emit(ClientMutationError(current, message));
    }
  }

  Future<void> _onAdminCreate(
    ClientAdminCreateRequested event,
    Emitter<ClientState> emit,
  ) async {
    final current = _current();
    emit(ClientMutating(current));
    final result = await _repo.createAdmin(event.clientId, event.data);
    switch (result) {
      case Success():
        emit(
          ClientMutationSuccess(current, 'Admin account created successfully'),
        );
      case Failure(:final message):
        emit(ClientMutationError(current, message));
    }
  }

  List<CorporateClient> _current() {
    final s = state;
    if (s is ClientLoaded) return s.clients;
    if (s is ClientMutating) return s.clients;
    if (s is ClientMutationSuccess) return s.clients;
    if (s is ClientMutationError) return s.clients;
    return [];
  }
}

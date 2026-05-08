import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/document_expiry_repo.dart';
import 'document_expiry_event.dart';
import 'document_expiry_state.dart';

class DocumentExpiryBloc
    extends Bloc<DocumentExpiryEvent, DocumentExpiryState> {
  final DocumentExpiryRepo _repo;

  DocumentExpiryBloc(this._repo) : super(DocumentExpiryInitial()) {
    on<DocumentExpiryLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DocumentExpiryLoadRequested event,
    Emitter<DocumentExpiryState> emit,
  ) async {
    emit(DocumentExpiryLoading());
    final result = await _repo.getExpiring();
    switch (result) {
      case Success(:final value):
        emit(DocumentExpiryLoaded(value));
      case Failure(:final message):
        emit(DocumentExpiryError(message));
    }
  }
}

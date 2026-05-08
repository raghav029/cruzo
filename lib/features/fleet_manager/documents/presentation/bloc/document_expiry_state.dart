import '../../domain/document_expiry.dart';

abstract class DocumentExpiryState {
  const DocumentExpiryState();
}

class DocumentExpiryInitial extends DocumentExpiryState {}

class DocumentExpiryLoading extends DocumentExpiryState {}

class DocumentExpiryLoaded extends DocumentExpiryState {
  final DocumentExpirySummary summary;
  const DocumentExpiryLoaded(this.summary);
}

class DocumentExpiryError extends DocumentExpiryState {
  final String message;
  const DocumentExpiryError(this.message);
}

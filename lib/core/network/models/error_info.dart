enum ErrorInfoType { clientError, serverError, parsingError }

class ErrorInfo {
  final String message;
  final int? code;
  final ErrorInfoType type;

  const ErrorInfo({required this.message, this.code, required this.type});

  factory ErrorInfo.fromException(Object e, {ErrorInfoType type = ErrorInfoType.parsingError}) {
    return ErrorInfo(message: e.toString(), code: null, type: type);
  }
}

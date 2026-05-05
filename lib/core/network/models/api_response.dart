import 'error_info.dart';

/// Lightweight API response model used by some service layers.
class APIResponse<T> {
  final T? data;
  final List<T>? dataList;
  final ErrorInfo? error;

  const APIResponse._({this.data, this.dataList, this.error});

  const APIResponse.success({T? data, List<T>? dataList}) : this._(data: data, dataList: dataList);

  const APIResponse.error(ErrorInfo error) : this._(error: error);

  bool get hasError => error != null;
}

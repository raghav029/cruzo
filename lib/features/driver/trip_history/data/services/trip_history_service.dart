import 'package:dio/dio.dart';

class TripHistoryService {
  TripHistoryService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchPage(int page, String? status) async {
    final params = <String, dynamic>{'page': page, 'size': 20};
    if (status != null) params['status'] = status;
    final resp = await _dio.get('/api/bookings', queryParameters: params);
    return resp.data['data'] as Map<String, dynamic>;
  }
}

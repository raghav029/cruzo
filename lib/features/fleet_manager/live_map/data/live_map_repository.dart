import 'package:dio/dio.dart';
import '../domain/live_trip.dart';

class LiveMapRepository {
  final Dio _dio;
  LiveMapRepository(this._dio);

  Future<List<LiveTrip>> getLiveTrips() async {
    final response = await _dio.get('/api/bookings/live');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => LiveTrip.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

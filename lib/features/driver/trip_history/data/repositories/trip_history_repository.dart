import 'package:cruzo/features/fleet_manager/bookings/domain/booking.dart';
import '../services/trip_history_service.dart';

class TripHistoryPage {
  final List<Booking> content;
  final bool isLast;
  const TripHistoryPage({required this.content, required this.isLast});
}

class TripHistoryRepository {
  TripHistoryRepository({required TripHistoryService service}) : _service = service;
  final TripHistoryService _service;

  Future<TripHistoryPage> fetchPage(int page, String? status) async {
    final data = await _service.fetchPage(page, status);
    final content = (data['content'] as List)
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
    return TripHistoryPage(content: content, isLast: data['last'] as bool);
  }
}

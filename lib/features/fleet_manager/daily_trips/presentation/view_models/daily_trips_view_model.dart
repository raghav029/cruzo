import 'package:flutter/foundation.dart';
import '../../../bookings/domain/booking.dart';
import '../../../bookings/domain/booking_repo.dart';
import '../../../../../core/network/result.dart';

class DailyTripsViewModel extends ChangeNotifier {
  DailyTripsViewModel({required BookingRepo bookingRepo}) : _repo = bookingRepo;

  final BookingRepo _repo;

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  Future<void> load(DateTime date) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final from = _dateParam(date);
    final to = _dateParam(date.add(const Duration(days: 1)));
    final result = await _repo.list(fromDate: from, toDate: to, size: 200);

    switch (result) {
      case Success(:final value):
        _bookings = value;
        _loading = false;
      case Failure(:final message):
        _error = message;
        _loading = false;
    }
    notifyListeners();
  }

  String _dateParam(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$mo-${day}T00:00:00Z';
  }
}

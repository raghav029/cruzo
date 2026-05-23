import 'package:flutter/foundation.dart';
import 'package:cruzo/core/network/result.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking_repo.dart';

class PendingBookingsCountNotifier extends ChangeNotifier {
  final BookingRepo _repo;

  PendingBookingsCountNotifier({required BookingRepo bookingRepo})
      : _repo = bookingRepo;

  int _count = 0;
  int get count => _count;

  Future<void> refresh() async {
    final result = await _repo.list(status: 'PENDING', size: 200);
    switch (result) {
      case Success(:final value):
        _count = value.length;
        notifyListeners();
      case Failure():
        break;
    }
  }
}

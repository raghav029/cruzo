import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/booking.dart';
import '../../domain/booking_repo.dart';
import '../../../../../core/network/result.dart';

class BookingDetailViewModel extends ChangeNotifier {
  BookingDetailViewModel({required BookingRepo bookingRepo}) : _repo = bookingRepo;

  final BookingRepo _repo;
  Timer? _pollTimer;

  late Booking _booking;
  Booking get booking => _booking;

  void init(Booking initial) {
    _booking = initial;
    if (initial.isActive) _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      final result = await _repo.getById(_booking.id);
      if (result case Success(:final value)) {
        _booking = value;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking.dart';
import '../../data/repositories/trip_history_repository.dart';

class TripHistoryViewModel extends ChangeNotifier {
  TripHistoryViewModel({required TripHistoryRepository repository}) : _repository = repository;
  final TripHistoryRepository _repository;

  final List<Booking> _trips = [];
  List<Booking> get trips => List.unmodifiable(_trips);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  int _page = 0;

  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  Future<void> load({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;
    if (reset) {
      _trips.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final page = await _repository.fetchPage(_page, _selectedStatus);
      _trips.addAll(page.content);
      _hasMore = !page.isLast;
      _page++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilter(String? status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    load(reset: true);
  }
}

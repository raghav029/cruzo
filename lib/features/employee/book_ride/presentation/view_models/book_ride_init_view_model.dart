import 'package:flutter/foundation.dart';
import '../../data/repositories/book_ride_init_repository.dart';

class BookRideInitViewModel extends ChangeNotifier {
  BookRideInitViewModel({required BookRideInitRepository repository}) : _repository = repository;
  final BookRideInitRepository _repository;

  BookRideInitData? _data;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get corporateClientId => _data?.corporateClientId;
  double? get maxBookingValue => _data?.maxBookingValue;
  List<String>? get allowedVehicleTypes => _data?.allowedVehicleTypes;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _repository.fetchInitData();
      if (_data?.corporateClientId == null) {
        _error = 'Account not linked to a corporate client. Contact your administrator.';
      }
    } catch (e) {
      _error = 'Failed to load booking details. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

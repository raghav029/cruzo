import 'package:flutter/foundation.dart';
import '../../data/repositories/book_ride_init_repository.dart';

class BookRideInitViewModel extends ChangeNotifier {
  BookRideInitViewModel({required BookRideInitRepository repository}) : _repository = repository;
  final BookRideInitRepository _repository;

  BookRideInitData? _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? get corporateClientId => _data?.corporateClientId;
  double? get maxBookingValue => _data?.maxBookingValue;
  List<String>? get allowedVehicleTypes => _data?.allowedVehicleTypes;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await _repository.fetchInitData();
    } catch (_) {
      _data = const BookRideInitData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

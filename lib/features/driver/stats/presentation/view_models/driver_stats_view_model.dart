import 'package:flutter/foundation.dart';
import '../../data/repositories/driver_stats_repository.dart';

class DriverStatsViewModel extends ChangeNotifier {
  DriverStatsViewModel({required DriverStatsRepository repository}) : _repository = repository;
  final DriverStatsRepository _repository;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _repository.fetchStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

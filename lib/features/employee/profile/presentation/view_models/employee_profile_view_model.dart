import 'package:flutter/foundation.dart';
import '../../data/repositories/employee_profile_repository.dart';

class EmployeeProfileViewModel extends ChangeNotifier {
  EmployeeProfileViewModel({required EmployeeProfileRepository repository}) : _repository = repository;
  final EmployeeProfileRepository _repository;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.fetchProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setProfile(Map<String, dynamic> data) {
    _profile = data;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) {
    return _repository.updateProfile(data);
  }
}

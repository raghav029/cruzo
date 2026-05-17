import 'package:flutter/foundation.dart';
import '../../../../../core/network/result.dart';
import '../../data/repositories/corp_admin_employee_repository.dart';
import '../../domain/corp_employee.dart';

class CorpEmployeesViewModel extends ChangeNotifier {
  CorpEmployeesViewModel({required CorpAdminEmployeeRepository repository})
      : _repo = repository;
  final CorpAdminEmployeeRepository _repo;

  String? _clientId;
  bool _isLoading = false;
  String? _error;
  List<CorpEmployee> _employees = [];

  String? _addError;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get addError => _addError;
  List<CorpEmployee> get employees => List.unmodifiable(_employees);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _clientId ??= await _repo.getMyClientId();
      if (_clientId == null) {
        // account not yet linked to a corporate client — show empty
        _employees = [];
      } else {
        final result = await _repo.listEmployees(_clientId!);
        switch (result) {
          case Success(:final value):
            _employees = value;
          case Failure(:final message):
            _error = message;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? dept,
    String? designation,
  }) async {
    _addError = null;
    if (_clientId == null) {
      _addError = 'Account not linked to a corporate client. Contact your fleet manager.';
      return false;
    }
    final result = await _repo.addEmployee(
      _clientId!,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      department: dept,
      designation: designation,
    );
    switch (result) {
      case Success(:final value):
        _employees = [..._employees, value];
        notifyListeners();
        return true;
      case Failure(:final message):
        _addError = message;
        return false;
    }
  }
}

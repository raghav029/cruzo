import 'package:flutter/foundation.dart';
import 'package:cruzo/core/network/result.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/domain/daily_schedule_models.dart';
import '../data/corp_admin_schedule_repository.dart';

class CorpAdminSchedulesViewModel extends ChangeNotifier {
  CorpAdminSchedulesViewModel({required CorpAdminScheduleRepository repository})
      : _repository = repository;
  final CorpAdminScheduleRepository _repository;

  bool isLoading = false;
  String? error;
  List<DailySchedule> schedules = [];
  String? _clientId;
  bool isMutating = false;
  String? mutationError;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    if (_clientId == null) {
      final clientResult = await _repository.fetchMyClientId();
      switch (clientResult) {
        case Success(:final value):
          _clientId = value;
        case Failure(:final message):
          error = message;
          isLoading = false;
          notifyListeners();
          return;
      }
    }

    final schedulesResult = await _repository.listSchedules();
    switch (schedulesResult) {
      case Success(:final value):
        schedules = value;
      case Failure(:final message):
        error = message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createSchedule({
    required String name,
    required String vehicleType,
    required List<String> recurrenceDays,
    required String pickupTime,
    required String dropAddress,
    required bool isPooled,
    required int maxCapacity,
  }) async {
    isMutating = true;
    mutationError = null;
    notifyListeners();

    final body = {
      'corporateClientId': _clientId,
      'name': name,
      'vehicleType': vehicleType,
      'recurrenceDays': recurrenceDays,
      'pickupTime': pickupTime,
      'dropAddress': dropAddress,
      'isPooled': isPooled,
      'maxCapacity': maxCapacity,
    };

    final result = await _repository.createSchedule(body);
    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
      case Failure(:final message):
        mutationError = message;
    }

    isMutating = false;
    notifyListeners();
    if (ok) await load();
    return ok;
  }

  Future<Result<List<DailySchedulePassenger>>> loadPassengers(String scheduleId) {
    return _repository.listPassengers(scheduleId);
  }

  Future<bool> enrollPassenger(
    String scheduleId, {
    required String employeeEmail,
    required String pickupAddress,
  }) async {
    isMutating = true;
    mutationError = null;
    notifyListeners();

    final result = await _repository.enrollPassenger(
      scheduleId,
      employeeEmail: employeeEmail,
      pickupAddress: pickupAddress,
    );
    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
      case Failure(:final message):
        mutationError = message;
    }

    isMutating = false;
    notifyListeners();
    return ok;
  }

  Future<bool> removePassenger(String scheduleId, String passengerId) async {
    isMutating = true;
    mutationError = null;
    notifyListeners();

    final result = await _repository.removePassenger(scheduleId, passengerId);
    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
      case Failure(:final message):
        mutationError = message;
    }

    isMutating = false;
    notifyListeners();
    return ok;
  }
}

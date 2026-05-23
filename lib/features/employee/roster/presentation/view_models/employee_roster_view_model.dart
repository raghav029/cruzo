import 'package:flutter/foundation.dart';
import '../../../../../core/network/result.dart';
import '../../../daily_schedule/domain/employee_schedule_repo.dart';
import '../../../daily_schedule/domain/employee_trip.dart';

class EmployeeRosterViewModel extends ChangeNotifier {
  EmployeeRosterViewModel({required EmployeeScheduleRepo repo}) : _repo = repo;
  final EmployeeScheduleRepo _repo;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get focusedMonth => _focusedMonth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, EmployeeTrip> _tripsByDate = {};
  Set<String> _skippedDates = {};

  bool hasTrip(DateTime day) => _tripsByDate.containsKey(_fmt(day));
  bool isSkipped(DateTime day) => _skippedDates.contains(_fmt(day));
  EmployeeTrip? tripFor(DateTime day) => _tripsByDate[_fmt(day)];

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadMonth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final result = await _repo.getScheduleForMonth(firstDay, lastDay);
    switch (result) {
      case Success(:final value):
        _tripsByDate = {for (final t in value) t.tripDate: t};
        final passengerIds = <String>{
          for (final trip in value)
            for (final p in trip.passengers) p.id,
        };
        final skipped = <String>{};
        for (final pid in passengerIds) {
          final r = await _repo.getSkipDates(pid);
          if (r case Success(:final value)) skipped.addAll(value);
        }
        _skippedDates = skipped;
      case Failure(:final message):
        _error = message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void goToPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    loadMonth();
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    loadMonth();
  }

  Future<String?> skipDate(String passengerId, DateTime date) async {
    final result = await _repo.skipDay(passengerId, _fmt(date));
    return switch (result) {
      Success() => null,
      Failure(:final message) => message,
    };
  }

  Future<String?> undoSkip(String passengerId, DateTime date) async {
    final result = await _repo.undoSkip(passengerId, _fmt(date));
    return switch (result) {
      Success() => null,
      Failure(:final message) => message,
    };
  }
}

import 'package:flutter/foundation.dart';
import '../../../../../core/network/result.dart';
import '../../../drivers/domain/driver_repo.dart';
import '../../../vehicles/domain/vehicle_repo.dart';
import '../../domain/booking.dart';

class AssignDriverViewModel extends ChangeNotifier {
  AssignDriverViewModel({
    required DriverRepo driverRepo,
    required VehicleRepo vehicleRepo,
  })  : _driverRepo = driverRepo,
        _vehicleRepo = vehicleRepo;

  final DriverRepo _driverRepo;
  final VehicleRepo _vehicleRepo;

  bool _loading = true;
  bool get isLoading => _loading;

  List<Map<String, String>> _drivers = [];
  List<Map<String, String>> get drivers => _drivers;

  List<Map<String, String>> _vehicles = [];
  List<Map<String, String>> get vehicles => _vehicles;

  Future<void> load(Booking booking) async {
    _loading = true;
    notifyListeners();

    final dr = await _driverRepo.list();
    final vr = await _vehicleRepo.list(status: 'ACTIVE');

    if (dr.isSuccess) {
      _drivers = dr.valueOrNull!
          .where((d) => d.availability == 'AVAILABLE')
          .map((d) => {'id': d.id, 'name': d.fullName, 'phone': d.phone})
          .toList();
    }
    if (vr.isSuccess) {
      _vehicles = vr.valueOrNull!
          .where((v) =>
              v.status == 'ACTIVE' &&
              (booking.vehicleTypeRequested == null ||
                  v.vehicleType == booking.vehicleTypeRequested))
          .map((v) => {'id': v.id, 'plate': v.plateNumber, 'type': v.vehicleType})
          .toList();
    }
    _loading = false;
    notifyListeners();
  }
}

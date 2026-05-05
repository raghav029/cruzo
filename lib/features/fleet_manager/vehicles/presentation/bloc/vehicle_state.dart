import '../../domain/vehicle.dart';

abstract class VehicleState {
  const VehicleState();
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final String? activeFilter;
  const VehicleLoaded(this.vehicles, {this.activeFilter});
}

class VehicleError extends VehicleState {
  final String message;
  const VehicleError(this.message);
}

class VehicleMutating extends VehicleState {
  final List<Vehicle> vehicles;
  const VehicleMutating(this.vehicles);
}

class VehicleMutationSuccess extends VehicleState {
  final List<Vehicle> vehicles;
  final String message;
  const VehicleMutationSuccess(this.vehicles, this.message);
}

class VehicleMutationError extends VehicleState {
  final List<Vehicle> vehicles;
  final String message;
  const VehicleMutationError(this.vehicles, this.message);
}

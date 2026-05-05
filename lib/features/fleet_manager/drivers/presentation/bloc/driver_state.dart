import '../../domain/driver.dart';

abstract class DriverState {
  const DriverState();
}

class DriverInitial extends DriverState {}
class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final List<Driver> drivers;
  const DriverLoaded(this.drivers);
}

class DriverError extends DriverState {
  final String message;
  const DriverError(this.message);
}

class DriverMutating extends DriverState {
  final List<Driver> drivers;
  const DriverMutating(this.drivers);
}

class DriverMutationSuccess extends DriverState {
  final List<Driver> drivers;
  final String message;
  const DriverMutationSuccess(this.drivers, this.message);
}

class DriverMutationError extends DriverState {
  final List<Driver> drivers;
  final String message;
  const DriverMutationError(this.drivers, this.message);
}

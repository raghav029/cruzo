import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../auth/auth_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/token_storage.dart';
import '../network/dio_client.dart';
import 'package:cruzo/features/fleet_manager/dashboard/data/dashboard_repository.dart';
import 'package:cruzo/features/fleet_manager/dashboard/domain/dashboard_repo.dart';
import 'package:cruzo/features/fleet_manager/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cruzo/features/fleet_manager/vehicles/data/vehicle_repository.dart';
import 'package:cruzo/features/fleet_manager/vehicles/domain/vehicle_repo.dart';
import 'package:cruzo/features/fleet_manager/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:cruzo/features/fleet_manager/drivers/data/driver_repository.dart';
import 'package:cruzo/features/fleet_manager/drivers/domain/driver_repo.dart';
import 'package:cruzo/features/fleet_manager/drivers/presentation/bloc/driver_bloc.dart';
import 'package:cruzo/features/fleet_manager/clients/data/client_repository.dart';
import 'package:cruzo/features/fleet_manager/clients/domain/client_repo.dart';
import 'package:cruzo/features/fleet_manager/clients/presentation/bloc/client_bloc.dart';
import 'package:cruzo/features/fleet_manager/bookings/data/booking_repository.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking_repo.dart';
import 'package:cruzo/features/fleet_manager/bookings/presentation/bloc/booking_bloc.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()));

  // Network
  getIt.registerLazySingleton<Dio>(() => DioClient.create(getIt()));

  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt(), getIt()),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));

  // Fleet Manager — Dashboard
  getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl(getIt()));
  getIt.registerFactory<DashboardBloc>(() => DashboardBloc(getIt()));

  // Fleet Manager — Vehicles
  getIt.registerLazySingleton<VehicleRepo>(() => VehicleRepoImpl(getIt()));
  getIt.registerFactory<VehicleBloc>(() => VehicleBloc(getIt()));

  // Fleet Manager — Drivers
  getIt.registerLazySingleton<DriverRepo>(() => DriverRepoImpl(getIt()));
  getIt.registerFactory<DriverBloc>(() => DriverBloc(getIt()));

  // Fleet Manager — Corporate Clients
  getIt.registerLazySingleton<ClientRepo>(() => ClientRepoImpl(getIt()));
  getIt.registerFactory<ClientBloc>(() => ClientBloc(getIt()));

  // Fleet Manager — Bookings
  getIt.registerLazySingleton<BookingRepo>(() => BookingRepoImpl(getIt()));
  getIt.registerFactory<BookingBloc>(() => BookingBloc(getIt()));
}

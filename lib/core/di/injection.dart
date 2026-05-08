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
import 'package:cruzo/features/fleet_manager/invoices/data/invoice_repository.dart';
import 'package:cruzo/features/fleet_manager/invoices/domain/invoice_repo.dart';
import 'package:cruzo/features/fleet_manager/invoices/presentation/bloc/invoice_bloc.dart';
import 'package:cruzo/features/fleet_manager/sos_alerts/data/sos_alert_repository.dart';
import 'package:cruzo/features/fleet_manager/sos_alerts/domain/sos_alert_repo.dart';
import 'package:cruzo/features/fleet_manager/sos_alerts/presentation/bloc/sos_alert_bloc.dart';
import 'package:cruzo/features/fleet_manager/documents/data/document_expiry_repository.dart';
import 'package:cruzo/features/fleet_manager/documents/domain/document_expiry_repo.dart';
import 'package:cruzo/features/fleet_manager/documents/presentation/bloc/document_expiry_bloc.dart';
import 'package:cruzo/features/fleet_manager/reports/data/report_repository.dart';
import 'package:cruzo/features/fleet_manager/reports/domain/report_repo.dart';
import 'package:cruzo/features/fleet_manager/reports/presentation/bloc/report_bloc.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/data/daily_schedule_repository.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/domain/daily_schedule_repo.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/presentation/bloc/daily_schedule_bloc.dart';
import '../theme/theme_service.dart';

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

  // Fleet Manager — Invoices
  getIt.registerLazySingleton<InvoiceRepo>(() => InvoiceRepoImpl(getIt()));
  getIt.registerFactory<InvoiceBloc>(() => InvoiceBloc(getIt()));

  // Fleet Manager — SOS Alerts
  getIt.registerLazySingleton<SosAlertRepo>(() => SosAlertRepoImpl(getIt()));
  getIt.registerFactory<SosAlertBloc>(() => SosAlertBloc(getIt()));

  // Fleet Manager — Documents
  getIt.registerLazySingleton<DocumentExpiryRepo>(() => DocumentExpiryRepoImpl(getIt()));
  getIt.registerFactory<DocumentExpiryBloc>(() => DocumentExpiryBloc(getIt()));

  // Fleet Manager — Daily Schedules
  getIt.registerLazySingleton<DailyScheduleRepo>(() => DailyScheduleRepoImpl(getIt()));
  getIt.registerFactory<DailyScheduleBloc>(() => DailyScheduleBloc(getIt()));

  // Fleet Manager — Reports
  getIt.registerLazySingleton<ReportRepo>(() => ReportRepoImpl(getIt()));
  getIt.registerFactory<ReportBloc>(() => ReportBloc(getIt()));

  // Theme service
  getIt.registerLazySingleton(() => ThemeService());
}

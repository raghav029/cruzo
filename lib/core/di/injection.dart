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
import '../maps/map_service.dart';
import '../maps/google/google_map_service.dart';
import 'package:cruzo/features/fleet_manager/live_map/data/live_map_repository.dart';
import 'package:cruzo/features/employee/daily_schedule/data/employee_schedule_repository.dart';
import 'package:cruzo/features/employee/daily_schedule/domain/employee_schedule_repo.dart';
import 'package:cruzo/features/employee/daily_schedule/presentation/bloc/employee_schedule_bloc.dart';
import 'package:cruzo/features/employee/book_ride/presentation/bloc/book_ride_bloc.dart';
import 'package:cruzo/features/driver/my_trip/data/driver_trip_repository.dart';
import 'package:cruzo/features/driver/my_trip/domain/driver_trip_repo.dart';
import 'package:cruzo/features/driver/my_trip/presentation/bloc/driver_trip_bloc.dart';
import 'package:cruzo/features/driver/location/driver_location_service.dart';
import 'package:cruzo/features/driver/profile/data/services/driver_profile_service.dart';
import 'package:cruzo/features/driver/profile/data/repositories/driver_profile_repository.dart';
import 'package:cruzo/features/driver/profile/presentation/view_models/driver_profile_view_model.dart';
import 'package:cruzo/features/driver/trip_history/data/services/trip_history_service.dart';
import 'package:cruzo/features/driver/trip_history/data/repositories/trip_history_repository.dart';
import 'package:cruzo/features/driver/trip_history/presentation/view_models/trip_history_view_model.dart';
import 'package:cruzo/features/driver/stats/data/services/driver_stats_service.dart';
import 'package:cruzo/features/driver/stats/data/repositories/driver_stats_repository.dart';
import 'package:cruzo/features/driver/stats/presentation/view_models/driver_stats_view_model.dart';
import 'package:cruzo/features/employee/profile/data/services/employee_profile_service.dart';
import 'package:cruzo/features/employee/profile/data/repositories/employee_profile_repository.dart';
import 'package:cruzo/features/employee/profile/presentation/view_models/employee_profile_view_model.dart';
import 'package:cruzo/features/employee/book_ride/data/services/book_ride_init_service.dart';
import 'package:cruzo/features/employee/book_ride/data/repositories/book_ride_init_repository.dart';
import 'package:cruzo/features/employee/book_ride/presentation/view_models/book_ride_init_view_model.dart';
import 'package:cruzo/features/employee/roster/presentation/view_models/employee_roster_view_model.dart';
import 'package:cruzo/features/fleet_manager/daily_trips/presentation/view_models/daily_trips_view_model.dart';
import 'package:cruzo/features/fleet_manager/bookings/presentation/view_models/booking_detail_view_model.dart';
import 'package:cruzo/features/fleet_manager/bookings/presentation/view_models/assign_driver_view_model.dart';
import 'package:cruzo/features/corporate_admin/employees/data/services/corp_admin_employee_service.dart';
import 'package:cruzo/features/corporate_admin/employees/data/repositories/corp_admin_employee_repository.dart';
import 'package:cruzo/features/corporate_admin/employees/presentation/view_models/corp_employees_view_model.dart';
import 'package:cruzo/features/corporate_admin/bookings/pending_count_notifier.dart';
import 'package:cruzo/features/corporate_admin/profile/data/services/corp_admin_profile_service.dart';
import 'package:cruzo/features/corporate_admin/profile/data/repositories/corp_admin_profile_repository.dart';
import 'package:cruzo/features/corporate_admin/profile/presentation/view_models/corp_admin_profile_view_model.dart';
import 'package:cruzo/features/corporate_admin/schedules/data/corp_admin_schedule_service.dart';
import 'package:cruzo/features/corporate_admin/schedules/data/corp_admin_schedule_repository.dart';
import 'package:cruzo/features/corporate_admin/schedules/presentation/corp_admin_schedules_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()));

  // Network
  getIt.registerLazySingleton<Dio>(() => DioClient.create(getIt()));

  // Maps
  getIt.registerLazySingleton<MapService>(() => GoogleMapService());
  getIt.registerLazySingleton<GoogleMapService>(() => GoogleMapService());

  // Fleet Manager — Live Map
  getIt.registerLazySingleton<LiveMapRepository>(() => LiveMapRepository(getIt<Dio>()));

  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt()));

  // Fleet Manager — Dashboard
  getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl(getIt()));
  getIt.registerLazySingleton<DashboardBloc>(() => DashboardBloc(getIt()));

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
  getIt.registerLazySingleton<DocumentExpiryRepo>(
    () => DocumentExpiryRepoImpl(getIt()),
  );
  getIt.registerFactory<DocumentExpiryBloc>(() => DocumentExpiryBloc(getIt()));

  // Fleet Manager — Daily Schedules
  getIt.registerLazySingleton<DailyScheduleRepo>(
    () => DailyScheduleRepoImpl(getIt()),
  );
  getIt.registerFactory<DailyScheduleBloc>(() => DailyScheduleBloc(getIt()));

  // Fleet Manager — Reports
  getIt.registerLazySingleton<ReportRepo>(() => ReportRepoImpl(getIt()));
  getIt.registerFactory<ReportBloc>(() => ReportBloc(getIt()));

  // Employee — Daily Schedule
  getIt.registerLazySingleton<EmployeeScheduleRepo>(
    () => EmployeeScheduleRepoImpl(getIt()),
  );
  getIt.registerFactory<EmployeeScheduleBloc>(
    () => EmployeeScheduleBloc(getIt()),
  );

  // Employee — Roster
  getIt.registerFactory(() => EmployeeRosterViewModel(repo: getIt<EmployeeScheduleRepo>()));

  // Employee — Book Ride (reuses BookingRepo)
  getIt.registerFactory<BookRideBloc>(() => BookRideBloc(getIt()));

  // Driver
  getIt.registerLazySingleton<DriverLocationService>(
    () => DriverLocationService(getIt()),
  );
  getIt.registerLazySingleton<DriverTripRepo>(
    () => DriverTripRepoImpl(getIt()),
  );
  getIt.registerFactory<DriverTripBloc>(() => DriverTripBloc(getIt(), getIt()));

  // Driver — Profile
  getIt.registerLazySingleton(() => DriverProfileService(dio: getIt()));
  getIt.registerLazySingleton(() => DriverProfileRepository(service: getIt()));
  getIt.registerFactory(() => DriverProfileViewModel(repository: getIt()));

  // Driver — Trip History
  getIt.registerLazySingleton(() => TripHistoryService(dio: getIt()));
  getIt.registerLazySingleton(() => TripHistoryRepository(service: getIt()));
  getIt.registerFactory(() => TripHistoryViewModel(repository: getIt()));

  // Driver — Stats
  getIt.registerLazySingleton(() => DriverStatsService(dio: getIt()));
  getIt.registerLazySingleton(() => DriverStatsRepository(service: getIt()));
  getIt.registerFactory(() => DriverStatsViewModel(repository: getIt()));

  // Employee — Profile
  getIt.registerLazySingleton(() => EmployeeProfileService(dio: getIt()));
  getIt.registerLazySingleton(
    () => EmployeeProfileRepository(service: getIt()),
  );
  getIt.registerFactory(() => EmployeeProfileViewModel(repository: getIt()));

  // Employee — Book Ride Init
  getIt.registerLazySingleton(() => BookRideInitService(dio: getIt()));
  getIt.registerLazySingleton(() => BookRideInitRepository(service: getIt()));
  getIt.registerFactory(() => BookRideInitViewModel(repository: getIt()));

  // Fleet Manager — Daily Trips ViewModel
  getIt.registerFactory(() => DailyTripsViewModel(bookingRepo: getIt()));

  // Fleet Manager — Booking Detail + Assign Driver
  getIt.registerFactory(() => BookingDetailViewModel(bookingRepo: getIt()));
  getIt.registerFactory(() => AssignDriverViewModel(driverRepo: getIt(), vehicleRepo: getIt()));

  // Corporate Admin — Employees
  getIt.registerLazySingleton(() => CorpAdminEmployeeService(dio: getIt()));
  getIt.registerLazySingleton(() => CorpAdminEmployeeRepository(service: getIt()));
  getIt.registerFactory(() => CorpEmployeesViewModel(repository: getIt()));

  // Corporate Admin — Profile
  getIt.registerLazySingleton(() => CorpAdminProfileService(dio: getIt()));
  getIt.registerLazySingleton(() => CorpAdminProfileRepository(service: getIt()));
  getIt.registerFactory(() => CorpAdminProfileViewModel(repository: getIt()));

  // Corporate Admin — Schedules
  getIt.registerLazySingleton(() => CorpAdminScheduleService(dio: getIt()));
  getIt.registerLazySingleton(() => CorpAdminScheduleRepository(service: getIt()));
  getIt.registerFactory(() => CorpAdminSchedulesViewModel(repository: getIt()));

  // Corporate Admin — Pending Bookings Badge
  getIt.registerLazySingleton(() => PendingBookingsCountNotifier(bookingRepo: getIt()));

  // Theme service
  getIt.registerLazySingleton(() => ThemeService());
}

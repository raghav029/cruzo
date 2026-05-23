import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/fleet_manager/shell/fleet_shell.dart';
import '../../features/fleet_manager/live_map/presentation/screens/live_map_screen.dart';
import '../../features/fleet_manager/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/fleet_manager/vehicles/presentation/screens/vehicles_screen.dart';
import '../../features/fleet_manager/vehicles/presentation/bloc/vehicle_bloc.dart';
import '../../features/fleet_manager/drivers/presentation/screens/drivers_screen.dart';
import '../../features/fleet_manager/drivers/presentation/bloc/driver_bloc.dart';
import '../../features/fleet_manager/clients/presentation/screens/clients_screen.dart';
import '../../features/fleet_manager/clients/presentation/bloc/client_bloc.dart';
import '../../features/fleet_manager/bookings/presentation/screens/bookings_screen.dart';
import '../../features/fleet_manager/bookings/presentation/bloc/booking_bloc.dart';
import '../../features/fleet_manager/invoices/presentation/screens/invoices_screen.dart';
import '../../features/fleet_manager/invoices/presentation/bloc/invoice_bloc.dart';
import '../../features/corporate_admin/invoices/presentation/screens/corp_admin_invoices_screen.dart';
import '../../features/corporate_admin/bookings/presentation/screens/corp_admin_bookings_screen.dart';
import '../../features/corporate_admin/reports/presentation/screens/corp_admin_reports_screen.dart';
import '../../features/fleet_manager/daily_trips/presentation/screens/daily_trips_screen.dart';
import '../../features/fleet_manager/sos_alerts/presentation/screens/sos_alerts_screen.dart';
import '../../features/fleet_manager/sos_alerts/presentation/bloc/sos_alert_bloc.dart';
import '../../features/fleet_manager/documents/presentation/screens/documents_screen.dart';
import '../../features/fleet_manager/documents/presentation/bloc/document_expiry_bloc.dart';
import '../../features/fleet_manager/reports/presentation/screens/reports_screen.dart';
import '../../features/fleet_manager/reports/presentation/bloc/report_bloc.dart';
import '../../features/fleet_manager/daily_schedules/presentation/screens/daily_schedules_screen.dart';
import '../../features/fleet_manager/daily_schedules/presentation/bloc/daily_schedule_bloc.dart';
import '../../features/employee/shell/employee_shell.dart';
import '../../features/corporate_admin/shell/corporate_admin_shell.dart';
import '../../features/employee/home/presentation/screens/employee_home_screen.dart';
import '../../features/employee/book_ride/presentation/bloc/book_ride_bloc.dart';
import '../../features/employee/book_ride/presentation/screens/employee_book_ride_screen.dart';
import '../../features/employee/my_trips/presentation/screens/employee_my_trips_screen.dart';
import '../../features/employee/daily_schedule/presentation/bloc/employee_schedule_bloc.dart';
import '../../features/employee/daily_schedule/presentation/screens/employee_daily_schedule_screen.dart';
import '../../features/employee/roster/presentation/screens/employee_roster_screen.dart';
import '../../features/employee/roster/presentation/view_models/employee_roster_view_model.dart';
import '../../features/driver/shell/driver_shell.dart';
import '../../features/driver/my_trip/presentation/bloc/driver_trip_bloc.dart';
import '../../features/driver/my_trip/presentation/screens/driver_home_screen.dart';
import '../../features/driver/profile/presentation/screens/driver_profile_screen.dart';
import '../../features/driver/trip_history/presentation/screens/driver_trip_history_screen.dart';
import '../../features/driver/stats/presentation/screens/driver_stats_screen.dart';
import '../../features/employee/profile/presentation/screens/employee_profile_screen.dart';
import '../../features/corporate_admin/employees/presentation/screens/corp_employees_screen.dart';
import '../../features/corporate_admin/employees/presentation/view_models/corp_employees_view_model.dart';
import '../../features/corporate_admin/profile/presentation/screens/corp_admin_profile_screen.dart';
import '../../features/corporate_admin/profile/presentation/view_models/corp_admin_profile_view_model.dart';
import '../../features/corporate_admin/schedules/presentation/corp_admin_schedules_screen.dart';
import '../../features/corporate_admin/schedules/presentation/corp_admin_schedules_view_model.dart';
import '../di/injection.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.loginPath,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = authBloc.state;
      final onLogin = state.matchedLocation == AppRoutes.loginPath;

      if (authState is AuthLoading || authState is AuthInitial) return null;
      if (authState is AuthUnauthenticated && !onLogin) return AppRoutes.loginPath;
      if (authState is AuthAuthenticated) {
        final loc = state.matchedLocation;
        final home = switch (authState.role) {
          AppRole.fleetManager => AppRoutes.fleetDashboardPath,
          AppRole.corporateAdmin => AppRoutes.corpAdminBookingsPath,
          AppRole.employee => AppRoutes.employeeHomePath,
          AppRole.driver => AppRoutes.driverMyTripPath,
          _ => AppRoutes.loginPath,
        };
        if (onLogin) return home;
        final isValidPath = switch (authState.role) {
          AppRole.fleetManager => loc.startsWith('/fleet/'),
          AppRole.corporateAdmin => loc.startsWith('/corp/'),
          AppRole.employee => loc.startsWith('/employee/'),
          AppRole.driver => loc.startsWith('/driver/'),
          _ => false,
        };
        if (!isValidPath) return home;
      }
      return null;
    },
    refreshListenable: _BlocListenable(authBloc),
    routes: [
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        builder: (_, __) => const LoginScreen(),
      ),

      // Fleet Manager routes
      ShellRoute(
        builder: (context, state, child) => FleetShell(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.fleetDashboard,
            path: AppRoutes.fleetDashboardPath,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            name: AppRoutes.fleetBookings,
            path: AppRoutes.fleetBookingsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<BookingBloc>(),
              child: const BookingsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetVehicles,
            path: AppRoutes.fleetVehiclesPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<VehicleBloc>(),
              child: const VehiclesScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetDrivers,
            path: AppRoutes.fleetDriversPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<DriverBloc>(),
              child: const DriversScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetClients,
            path: AppRoutes.fleetClientsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<ClientBloc>(),
              child: const ClientsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetDailyTrips,
            path: AppRoutes.fleetDailyTripsPath,
            builder: (_, __) => const DailyTripsScreen(),
          ),
          GoRoute(
            name: AppRoutes.fleetDailySchedules,
            path: AppRoutes.fleetDailySchedulesPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<DailyScheduleBloc>(),
              child: const DailySchedulesScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetInvoices,
            path: AppRoutes.fleetInvoicesPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<InvoiceBloc>(),
              child: const InvoicesScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetReports,
            path: AppRoutes.fleetReportsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<ReportBloc>(),
              child: const ReportsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetSosAlerts,
            path: AppRoutes.fleetSosAlertsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<SosAlertBloc>(),
              child: const SosAlertsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetDocuments,
            path: AppRoutes.fleetDocumentsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<DocumentExpiryBloc>(),
              child: const DocumentsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.fleetLiveMap,
            path: AppRoutes.fleetLiveMapPath,
            builder: (_, __) => const LiveMapScreen(),
          ),
        ],
      ),

      // Employee routes
      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<BookingBloc>()),
            BlocProvider(create: (_) => getIt<EmployeeScheduleBloc>()),
            BlocProvider(create: (_) => getIt<BookRideBloc>()),
          ],
          child: EmployeeShell(child: child),
        ),
        routes: [
          GoRoute(
            name: AppRoutes.employeeHome,
            path: AppRoutes.employeeHomePath,
            builder: (_, __) => const EmployeeHomeScreen(),
          ),
          GoRoute(
            name: AppRoutes.employeeBookRide,
            path: AppRoutes.employeeBookRidePath,
            builder: (_, __) => const EmployeeBookRideScreen(),
          ),
          GoRoute(
            name: AppRoutes.employeeMyTrips,
            path: AppRoutes.employeeMyTripsPath,
            builder: (_, __) => const EmployeeMyTripsScreen(),
          ),
          GoRoute(
            name: AppRoutes.employeeDailySchedule,
            path: AppRoutes.employeeDailySchedulePath,
            builder: (_, __) => EmployeeRosterScreen(viewModel: getIt<EmployeeRosterViewModel>()),
          ),
          GoRoute(
            name: AppRoutes.employeeProfile,
            path: AppRoutes.employeeProfilePath,
            builder: (_, __) => const EmployeeProfileScreen(),
          ),
        ],
      ),

      // Corporate Admin routes
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => getIt<BookingBloc>(),
          child: CorporateAdminShell(child: child),
        ),
        routes: [
          GoRoute(
            name: AppRoutes.corpAdminBookings,
            path: AppRoutes.corpAdminBookingsPath,
            builder: (_, __) => const CorpAdminBookingsScreen(),
          ),
          GoRoute(
            name: AppRoutes.corpAdminInvoices,
            path: AppRoutes.corpAdminInvoicesPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<InvoiceBloc>(),
              child: const CorpAdminInvoicesScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.corpAdminReports,
            path: AppRoutes.corpAdminReportsPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<ReportBloc>(),
              child: const CorpAdminReportsScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.corpAdminEmployees,
            path: AppRoutes.corpAdminEmployeesPath,
            builder: (_, __) => CorpEmployeesScreen(
              viewModel: getIt<CorpEmployeesViewModel>(),
            ),
          ),
          GoRoute(
            name: AppRoutes.corpAdminProfile,
            path: AppRoutes.corpAdminProfilePath,
            builder: (_, __) => CorpAdminProfileScreen(
              viewModel: getIt<CorpAdminProfileViewModel>(),
            ),
          ),
          GoRoute(
            name: AppRoutes.corpAdminSchedules,
            path: AppRoutes.corpAdminSchedulesPath,
            builder: (_, __) => CorpAdminSchedulesScreen(
              viewModel: getIt<CorpAdminSchedulesViewModel>(),
            ),
          ),
        ],
      ),

      // Driver routes
      ShellRoute(
        builder: (_, __, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.driverMyTrip,
            path: AppRoutes.driverMyTripPath,
            builder: (_, __) => BlocProvider(
              create: (_) => getIt<DriverTripBloc>(),
              child: const DriverHomeScreen(),
            ),
          ),
          GoRoute(
            name: AppRoutes.driverProfile,
            path: AppRoutes.driverProfilePath,
            builder: (_, __) => const DriverProfileScreen(),
          ),
          GoRoute(
            name: AppRoutes.driverTripHistory,
            path: AppRoutes.driverTripHistoryPath,
            builder: (_, __) => const DriverTripHistoryScreen(),
          ),
          GoRoute(
            name: AppRoutes.driverStats,
            path: AppRoutes.driverStatsPath,
            builder: (_, __) => const DriverStatsScreen(),
          ),
        ],
      ),
    ],
  );
}

class _BlocListenable extends ChangeNotifier {
  _BlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

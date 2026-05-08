import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/fleet_manager/shell/fleet_shell.dart';
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
import '../../features/fleet_manager/daily_trips/presentation/screens/daily_trips_screen.dart';
import '../../features/fleet_manager/sos_alerts/presentation/screens/sos_alerts_screen.dart';
import '../../features/fleet_manager/sos_alerts/presentation/bloc/sos_alert_bloc.dart';
import '../../features/fleet_manager/documents/presentation/screens/documents_screen.dart';
import '../../features/fleet_manager/documents/presentation/bloc/document_expiry_bloc.dart';
import '../../features/fleet_manager/reports/presentation/screens/reports_screen.dart';
import '../../features/fleet_manager/reports/presentation/bloc/report_bloc.dart';
import '../../features/fleet_manager/daily_schedules/presentation/screens/daily_schedules_screen.dart';
import '../../features/fleet_manager/daily_schedules/presentation/bloc/daily_schedule_bloc.dart';
import '../di/injection.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.loginPath,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = authBloc.state;
      final onLogin = state.matchedLocation == AppRoutes.loginPath;

      if (authState is AuthLoading || authState is AuthInitial) return null;
      if (authState is AuthUnauthenticated && !onLogin)
        return AppRoutes.loginPath;
      if (authState is AuthAuthenticated && onLogin) {
        return switch (authState.role) {
          AppRole.fleetManager => AppRoutes.fleetDashboardPath,
          AppRole.employee => AppRoutes.employeeHomePath,
          AppRole.driver => AppRoutes.driverMyTripPath,
          _ => AppRoutes.fleetDashboardPath,
        };
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
        ],
      ),

      // Employee routes
      GoRoute(
        name: AppRoutes.employeeHome,
        path: AppRoutes.employeeHomePath,
        builder: (_, __) => const _Placeholder('Employee Home'),
      ),

      // Driver routes
      GoRoute(
        name: AppRoutes.driverMyTrip,
        path: AppRoutes.driverMyTripPath,
        builder: (_, __) => const _Placeholder('Driver Trip'),
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

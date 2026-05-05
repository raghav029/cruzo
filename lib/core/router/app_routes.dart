abstract final class AppRoutes {
  // Auth
  static const login = 'login';
  static const loginPath = '/login';

  // Fleet Manager
  static const fleetDashboard = 'fleet-dashboard';
  static const fleetDashboardPath = '/fleet/dashboard';
  static const fleetVehicles = 'fleet-vehicles';
  static const fleetVehiclesPath = '/fleet/vehicles';
  static const fleetDrivers = 'fleet-drivers';
  static const fleetDriversPath = '/fleet/drivers';
  static const fleetClients = 'fleet-clients';
  static const fleetClientsPath = '/fleet/clients';
  static const fleetBookings = 'fleet-bookings';
  static const fleetBookingsPath = '/fleet/bookings';
  static const fleetDailyTrips = 'fleet-daily-trips';
  static const fleetDailyTripsPath = '/fleet/daily-trips';
  static const fleetDailySchedules = 'fleet-daily-schedules';
  static const fleetDailySchedulesPath = '/fleet/daily-schedules';
  static const fleetInvoices = 'fleet-invoices';
  static const fleetInvoicesPath = '/fleet/invoices';
  static const fleetSosAlerts = 'fleet-sos-alerts';
  static const fleetSosAlertsPath = '/fleet/sos';
  static const fleetDocuments = 'fleet-documents';
  static const fleetDocumentsPath = '/fleet/documents';
  static const fleetReports = 'fleet-reports';
  static const fleetReportsPath = '/fleet/reports';

  // Employee
  static const employeeHome = 'employee-home';
  static const employeeHomePath = '/employee/home';
  static const employeeBookRide = 'employee-book-ride';
  static const employeeBookRidePath = '/employee/book-ride';
  static const employeeMyTrips = 'employee-my-trips';
  static const employeeMyTripsPath = '/employee/my-trips';
  static const employeeDailySchedule = 'employee-daily-schedule';
  static const employeeDailySchedulePath = '/employee/daily-schedule';

  // Driver
  static const driverMyTrip = 'driver-my-trip';
  static const driverMyTripPath = '/driver/trip';
}

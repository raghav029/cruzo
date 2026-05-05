class DashboardSummary {
  final int tripsToday;
  final int activeTrips;
  final int pendingApprovals;
  final int unassignedTrips;
  final int totalVehicles;
  final int vehiclesInTrip;
  final int totalDrivers;
  final int availableDrivers;
  final int pendingInvoices;
  final int activeSosAlerts;
  final int expiringDocuments;
  final int totalBookingsThisMonth;
  final double revenueThisMonth;

  const DashboardSummary({
    required this.tripsToday,
    required this.activeTrips,
    required this.pendingApprovals,
    required this.unassignedTrips,
    required this.totalVehicles,
    required this.vehiclesInTrip,
    required this.totalDrivers,
    required this.availableDrivers,
    required this.pendingInvoices,
    required this.activeSosAlerts,
    required this.expiringDocuments,
    required this.totalBookingsThisMonth,
    required this.revenueThisMonth,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        tripsToday: json['tripsToday'] ?? 0,
        activeTrips: json['activeTrips'] ?? 0,
        pendingApprovals: json['pendingApprovals'] ?? 0,
        unassignedTrips: json['unassignedTrips'] ?? 0,
        totalVehicles: json['totalVehicles'] ?? 0,
        vehiclesInTrip: json['vehiclesInTrip'] ?? 0,
        totalDrivers: json['totalDrivers'] ?? 0,
        availableDrivers: json['availableDrivers'] ?? 0,
        pendingInvoices: json['pendingInvoices'] ?? 0,
        activeSosAlerts: json['activeSosAlerts'] ?? 0,
        expiringDocuments: json['expiringDocuments'] ?? 0,
        totalBookingsThisMonth: json['totalBookingsThisMonth'] ?? 0,
        revenueThisMonth: (json['revenueThisMonth'] ?? 0).toDouble(),
      );
}

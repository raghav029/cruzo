class TripHourStat {
  final String label;
  final double value;
  const TripHourStat({required this.label, required this.value});

  factory TripHourStat.fromJson(Map<String, dynamic> j) =>
      TripHourStat(label: j['label'] ?? '', value: (j['value'] ?? 0).toDouble());
}

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

  final List<double> tripsSparkData;
  final List<double> revenueSparkData;
  final List<double> unassignedSparkData;

  final List<TripHourStat> tripsByHourToday;
  final List<TripHourStat> tripsByHour7d;
  final List<TripHourStat> tripsByHour30d;

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
    required this.tripsSparkData,
    required this.revenueSparkData,
    required this.unassignedSparkData,
    required this.tripsByHourToday,
    required this.tripsByHour7d,
    required this.tripsByHour30d,
  });

  static List<double> _parseDoubleList(dynamic v) {
    if (v == null) return [];
    return (v as List).map((e) => (e as num).toDouble()).toList();
  }

  static List<TripHourStat> _parseHourly(dynamic v) {
    if (v == null) return [];
    return (v as List).map((e) => TripHourStat.fromJson(e as Map<String, dynamic>)).toList();
  }

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
        tripsSparkData: _parseDoubleList(json['tripsSparkData']),
        revenueSparkData: _parseDoubleList(json['revenueSparkData']),
        unassignedSparkData: _parseDoubleList(json['unassignedSparkData']),
        tripsByHourToday: _parseHourly(json['tripsByHourToday']),
        tripsByHour7d: _parseHourly(json['tripsByHour7d']),
        tripsByHour30d: _parseHourly(json['tripsByHour30d']),
      );
}

class DriverStat {
  final String driverName;
  final int completedTrips;

  const DriverStat({required this.driverName, required this.completedTrips});

  factory DriverStat.fromJson(Map<String, dynamic> j) => DriverStat(
        driverName: j['driverName'] as String,
        completedTrips: (j['completedTrips'] as num).toInt(),
      );
}

class VehicleUtilization {
  final String plateNumber;
  final String vehicleType;
  final int trips;

  const VehicleUtilization({
    required this.plateNumber,
    required this.vehicleType,
    required this.trips,
  });

  factory VehicleUtilization.fromJson(Map<String, dynamic> j) =>
      VehicleUtilization(
        plateNumber: j['plateNumber'] as String,
        vehicleType: j['vehicleType'] as String,
        trips: (j['trips'] as num).toInt(),
      );
}

class FleetSummary {
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double averageFare;
  final List<DriverStat> topDrivers;
  final List<VehicleUtilization> vehicleUtilization;

  const FleetSummary({
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.averageFare,
    required this.topDrivers,
    required this.vehicleUtilization,
  });

  factory FleetSummary.fromJson(Map<String, dynamic> j) => FleetSummary(
        totalBookings: (j['totalBookings'] as num).toInt(),
        completedBookings: (j['completedBookings'] as num).toInt(),
        cancelledBookings: (j['cancelledBookings'] as num).toInt(),
        totalRevenue: (j['totalRevenue'] as num).toDouble(),
        averageFare: (j['averageFare'] as num).toDouble(),
        topDrivers: (j['topDrivers'] as List)
            .map((e) => DriverStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        vehicleUtilization: (j['vehicleUtilization'] as List)
            .map((e) => VehicleUtilization.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class EmployeeStat {
  final String employeeName;
  final int trips;
  final double totalSpend;

  const EmployeeStat({
    required this.employeeName,
    required this.trips,
    required this.totalSpend,
  });

  factory EmployeeStat.fromJson(Map<String, dynamic> j) => EmployeeStat(
        employeeName: j['employeeName'] as String,
        trips: (j['trips'] as num).toInt(),
        totalSpend: (j['totalSpend'] as num).toDouble(),
      );
}

class MonthlyBreakdown {
  final String month;
  final int trips;
  final double spend;

  const MonthlyBreakdown({
    required this.month,
    required this.trips,
    required this.spend,
  });

  factory MonthlyBreakdown.fromJson(Map<String, dynamic> j) => MonthlyBreakdown(
        month: j['month'] as String,
        trips: (j['trips'] as num).toInt(),
        spend: (j['spend'] as num).toDouble(),
      );
}

class CorporateSpend {
  final int totalBookings;
  final double totalSpend;
  final List<EmployeeStat> topEmployees;
  final List<MonthlyBreakdown> monthlyBreakdown;

  const CorporateSpend({
    required this.totalBookings,
    required this.totalSpend,
    required this.topEmployees,
    required this.monthlyBreakdown,
  });

  factory CorporateSpend.fromJson(Map<String, dynamic> j) => CorporateSpend(
        totalBookings: (j['totalBookings'] as num).toInt(),
        totalSpend: (j['totalSpend'] as num).toDouble(),
        topEmployees: (j['topEmployees'] as List)
            .map((e) => EmployeeStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyBreakdown: (j['monthlyBreakdown'] as List)
            .map((e) => MonthlyBreakdown.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

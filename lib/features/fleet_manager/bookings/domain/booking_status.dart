import 'package:flutter/material.dart';
import '../../../../core/theme/dls/dls.dart';

/// Enum representing all possible booking/trip status values.
/// Centralized to replace scattered hardcoded status strings across the codebase.
enum BookingStatus {
  /// Initial state: booking awaiting approval
  pendingApproval('PENDING_APPROVAL'),

  /// Booking has been approved by fleet manager
  approved('APPROVED'),

  /// Driver has been assigned to the trip
  driverAssigned('DRIVER_ASSIGNED'),

  /// Driver is en route to pickup location
  driverEnRoute('DRIVER_EN_ROUTE'),

  /// Driver has arrived at pickup location
  arrived('ARRIVED'),

  /// Trip is currently in progress (passenger picked up)
  inProgress('IN_PROGRESS'),

  /// Trip completed successfully
  completed('COMPLETED'),

  /// Trip cancelled (generic daily-trip status)
  cancelled('CANCELLED'),

  /// Cancelled by the employee/passenger
  cancelledByEmployee('CANCELLED_BY_EMPLOYEE'),

  /// Cancelled by admin
  cancelledByAdmin('CANCELLED_BY_ADMIN'),

  /// Cancelled by fleet manager
  cancelledByFleetManager('CANCELLED_BY_FLEET_MANAGER'),

  /// Cancelled by driver
  cancelledByDriver('CANCELLED_BY_DRIVER'),

  /// Booking was rejected
  rejected('REJECTED'),

  /// Trip is scheduled (used in daily trips)
  scheduled('SCHEDULED');

  /// Raw string value from backend API
  final String rawValue;

  const BookingStatus(this.rawValue);

  /// Parse string from API into enum, defaults to [pendingApproval] if unknown
  static BookingStatus fromString(String? value) {
    return values.firstWhere(
      (status) => status.rawValue == value,
      orElse: () => BookingStatus.pendingApproval,
    );
  }

  /// Get display name for UI
  String get displayName => switch (this) {
    BookingStatus.pendingApproval => 'Pending',
    BookingStatus.approved => 'Approved',
    BookingStatus.driverAssigned => 'Driver Assigned',
    BookingStatus.driverEnRoute => 'En Route',
    BookingStatus.arrived => 'Arrived',
    BookingStatus.inProgress => 'In Progress',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.cancelledByEmployee => 'Cancelled',
    BookingStatus.cancelledByAdmin => 'Cancelled',
    BookingStatus.cancelledByFleetManager => 'Cancelled',
    BookingStatus.cancelledByDriver => 'Cancelled (Driver)',
    BookingStatus.rejected => 'Rejected',
    BookingStatus.scheduled => 'Scheduled',
  };

  /// Get short display name (for compact UI)
  String get shortName => switch (this) {
    BookingStatus.pendingApproval => 'Pending',
    BookingStatus.approved => 'Approved',
    BookingStatus.driverAssigned => 'Assigned',
    BookingStatus.driverEnRoute => 'En Route',
    BookingStatus.arrived => 'Arrived',
    BookingStatus.inProgress => 'En route',
    BookingStatus.completed => 'Done',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.cancelledByEmployee => 'Cancelled',
    BookingStatus.cancelledByAdmin => 'Cancelled',
    BookingStatus.cancelledByFleetManager => 'Cancelled',
    BookingStatus.cancelledByDriver => 'Cancelled',
    BookingStatus.rejected => 'Rejected',
    BookingStatus.scheduled => 'Scheduled',
  };

  /// Get semantic color for this status
  Color get color => switch (this) {
    BookingStatus.completed => AppColors.good,
    BookingStatus.cancelled => AppColors.bad,
    BookingStatus.inProgress ||
    BookingStatus.driverEnRoute ||
    BookingStatus.arrived => AppColors.accent,
    BookingStatus.cancelledByEmployee ||
    BookingStatus.cancelledByAdmin ||
    BookingStatus.cancelledByFleetManager ||
    BookingStatus.cancelledByDriver ||
    BookingStatus.rejected => AppColors.bad,
    BookingStatus.driverAssigned => AppColors.info,
    BookingStatus.approved => AppColors.warn,
    _ => AppColors.darkFg3,
  };

  /// Get background color for this status badge
  Color get backgroundColor => switch (this) {
    BookingStatus.completed => AppColors.goodBg,
    BookingStatus.cancelled => AppColors.badBg,
    BookingStatus.inProgress ||
    BookingStatus.driverEnRoute ||
    BookingStatus.arrived => AppColors.accentBg,
    BookingStatus.cancelledByEmployee ||
    BookingStatus.cancelledByAdmin ||
    BookingStatus.cancelledByFleetManager ||
    BookingStatus.cancelledByDriver ||
    BookingStatus.rejected => AppColors.badBg,
    BookingStatus.driverAssigned => AppColors.infoBg,
    BookingStatus.approved => AppColors.warnBg,
    _ => AppColors.darkBg3,
  };

  /// Check if trip is in any active/ongoing state
  bool get isActive => switch (this) {
    BookingStatus.inProgress ||
    BookingStatus.driverEnRoute ||
    BookingStatus.arrived ||
    BookingStatus.driverAssigned => true,
    _ => false,
  };

  /// Check if trip is completed
  bool get isCompleted => this == BookingStatus.completed;

  /// Check if trip is in any cancelled state
  bool get isCancelled => switch (this) {
    BookingStatus.cancelledByEmployee ||
    BookingStatus.cancelledByAdmin ||
    BookingStatus.cancelledByFleetManager ||
    BookingStatus.cancelledByDriver ||
    BookingStatus.cancelled => true,
    _ => false,
  };

  /// Check if trip requires driver assignment
  bool get needsDriver => this == BookingStatus.approved;

  /// Check if trip is awaiting approval/scheduling
  bool get isPending => this == BookingStatus.pendingApproval;

  /// Check if driver is on the way or at location
  bool get isDriverMoving => switch (this) {
    BookingStatus.driverAssigned ||
    BookingStatus.driverEnRoute ||
    BookingStatus.arrived => true,
    _ => false,
  };
}

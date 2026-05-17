# BookingStatus Enum - Quick Start Guide

## 🎯 What You Need to Know

You have **137+ hardcoded status strings** scattered across 12 Dart files. These represent a significant source of bugs, typos, and maintenance headaches.

**Solution:** `BookingStatus` enum is now ready to use!

---

## 📦 The Enum (Location)

```
lib/features/fleet_manager/bookings/domain/booking_status.dart
```

### Import It
```dart
import 'package:cruzo/features/fleet_manager/bookings/domain/booking_status.dart';
```

---

## ✨ What's Available

### 1. Parse Strings from API
```dart
// API returns: { "status": "IN_PROGRESS" }
BookingStatus status = BookingStatus.fromString(booking.status);
```

### 2. Display Names (UI Text)
```dart
status.displayName    // "In Progress" - full name for UI
status.shortName      // "En route"    - short variant

// Examples:
BookingStatus.driverAssigned.displayName  // "Driver Assigned"
BookingStatus.cancelledByDriver.displayName // "Cancelled (Driver)"
```

### 3. Colors (from DLS)
```dart
status.color               // Color for text/icon
status.backgroundColor     // Color for badge background

// Examples:
BookingStatus.completed.color           // AppColors.good (green)
BookingStatus.inProgress.color          // AppColors.accent (blue)
BookingStatus.cancelledByEmployee.color // AppColors.bad (red)
```

### 4. Logical Checks (Helpers)
```dart
status.isActive         // true if DRIVER_EN_ROUTE, ARRIVED, IN_PROGRESS, DRIVER_ASSIGNED
status.isCompleted      // true if COMPLETED
status.isCancelled      // true if any cancelled state
status.isPending        // true if PENDING_APPROVAL
status.needsDriver      // true if APPROVED (needs assignment)
status.isDriverMoving   // true if driver is moving/en route
```

---

## 📝 Refactoring Examples

### Before (String Comparisons - Error Prone)
```dart
String status = booking.status;

// ❌ Hardcoded strings everywhere
if (status == 'COMPLETED') {
  color = AppColors.good;
} else if (status == 'IN_PROGRESS' || status == 'DRIVER_EN_ROUTE') {
  color = AppColors.accent;
} else if (status == 'CANCELLED_BY_EMPLOYEE' || status == 'CANCELLED_BY_ADMIN') {
  color = AppColors.bad;
}

// ❌ Manual display name mapping
String displayName = status == 'PENDING_APPROVAL' ? 'Pending' : 
                     status == 'APPROVED' ? 'Approved' : 
                     status.replaceAll('_', ' ');

// ❌ Filtering with string comparison
needsDriver = booking.status == 'APPROVED';
```

### After (Type Safe - Using Enum)
```dart
BookingStatus status = BookingStatus.fromString(booking.status);

// ✅ One property for color
color = status.color;

// ✅ One property for display name
String displayName = status.displayName;

// ✅ Semantic check instead of string comparison
if (status.needsDriver) {
  // assign driver UI
}

// ✅ Use logic helpers
if (status.isActive) { /* ... */ }
if (status.isCancelled) { /* ... */ }
```

---

## 🔄 Switch Statement Simplification

### Before
```dart
String displayName = switch (booking.status) {
  'PENDING_APPROVAL' => 'Pending',
  'APPROVED' => 'Approved',
  'DRIVER_ASSIGNED' => 'Driver Assigned',
  'DRIVER_EN_ROUTE' => 'En Route',
  'ARRIVED' => 'Arrived',
  'IN_PROGRESS' => 'In Progress',
  'COMPLETED' => 'Completed',
  'CANCELLED_BY_EMPLOYEE' => 'Cancelled',
  'CANCELLED_BY_ADMIN' => 'Cancelled',
  'CANCELLED_BY_FLEET_MANAGER' => 'Cancelled',
  'CANCELLED_BY_DRIVER' => 'Cancelled (Driver)',
  'REJECTED' => 'Rejected',
  _ => 'Unknown',
};
```

### After
```dart
BookingStatus status = BookingStatus.fromString(booking.status);
String displayName = status.displayName;  // Done!
```

---

## 📊 Color Badge Example

### Before (10 lines of duplication)
```dart
// In employee_my_trips_screen.dart
final statusColor = switch (booking.status) {
  'COMPLETED' => AppColors.good,
  'IN_PROGRESS' || 'DRIVER_EN_ROUTE' || 'ARRIVED' => AppColors.accent,
  'CANCELLED_BY_EMPLOYEE' || ... => AppColors.bad,
  _ => AppColors.warn,
};

// In daily_trips_screen.dart
final statusColor = switch (booking.status) {
  'IN_PROGRESS' || 'DRIVER_EN_ROUTE' || 'ARRIVED' => AppColors.good,
  'DRIVER_ASSIGNED' => AppColors.info,
  'APPROVED' => AppColors.warn,
  // ... repeated everywhere
};
```

### After (One line, everywhere)
```dart
final statusColor = BookingStatus.fromString(booking.status).color;
```

---

## 🎨 All 13 Status Values

```dart
BookingStatus.pendingApproval          // Initial state
BookingStatus.approved                 // Approved by manager
BookingStatus.driverAssigned           // Driver assigned
BookingStatus.driverEnRoute            // Driver en route
BookingStatus.arrived                  // Driver at pickup
BookingStatus.inProgress               // Trip ongoing
BookingStatus.completed                // Trip done
BookingStatus.cancelledByEmployee      // Cancelled by employee
BookingStatus.cancelledByAdmin         // Cancelled by admin
BookingStatus.cancelledByFleetManager  // Cancelled by manager
BookingStatus.cancelledByDriver        // Cancelled by driver
BookingStatus.rejected                 // Booking rejected
BookingStatus.scheduled                // Trip scheduled
```

---

## 🚀 Next Steps

1. **Import the enum** in screens that use status strings
2. **Replace string comparisons** with `BookingStatus.fromString(booking.status)`
3. **Use enum properties** instead of switch statements
4. **Simplify filter lists** to use enum values

---

## 📌 Files Ready to Refactor

High priority (start here):
- `lib/features/employee/my_trips/presentation/screens/employee_my_trips_screen.dart`
- `lib/features/employee/home/presentation/screens/employee_home_screen.dart`

Medium priority:
- `lib/features/fleet_manager/daily_trips/presentation/screens/daily_trips_screen.dart`
- `lib/features/driver/my_trip/presentation/screens/driver_booking_trip_screen.dart`

---

## 🔗 Related Documentation

- `BOOKING_STATUS_SUMMARY.md` - Complete features list and benefits
- `BOOKING_STATUS_INVENTORY.md` - Detailed file-by-file inventory
- `STATUS_ENUM_MIGRATION.md` - Migration strategy

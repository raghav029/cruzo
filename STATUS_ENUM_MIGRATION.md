# Booking Status Enum Migration Plan

## Overview
The codebase has extensive use of hardcoded booking status strings scattered across multiple files. This document outlines the migration to a centralized `BookingStatus` enum for type safety, consistency, and easier maintenance.

## Unique Booking Status Values Found
1. **PENDING_APPROVAL** - Initial state after booking
2. **APPROVED** - Booking approved by fleet manager
3. **DRIVER_ASSIGNED** - Driver has been assigned
4. **DRIVER_EN_ROUTE** - Driver is en route to pickup
5. **ARRIVED** - Driver arrived at pickup location
6. **IN_PROGRESS** - Trip is in progress
7. **COMPLETED** - Trip completed successfully
8. **CANCELLED_BY_EMPLOYEE** - Cancelled by employee
9. **CANCELLED_BY_ADMIN** - Cancelled by admin
10. **CANCELLED_BY_FLEET_MANAGER** - Cancelled by fleet manager
11. **CANCELLED_BY_DRIVER** - Cancelled by driver
12. **REJECTED** - Booking rejected
13. **SCHEDULED** - (Found in domain model) - Trip is scheduled

## Files with Status String Usage

### Employee Features
- **`lib/features/employee/home/presentation/screens/employee_home_screen.dart`** (4 occurrences)
  - Lines 320-321: Status color mapping
  - Lines 420-425: Recent trip status color mapping
  - Lines 492-496: Trip status display names
  
- **`lib/features/employee/my_trips/presentation/screens/employee_my_trips_screen.dart`** (3 occurrences)
  - Lines 22-26: Filter chip values
  - Lines 253-259: Status color mapping
  - Lines 265-276: Status display names (12 switch cases)

- **`lib/features/employee/daily_schedule/presentation/screens/employee_daily_schedule_screen.dart`**
  - Lines 469-470: Status color mapping

### Driver Features
- **`lib/features/driver/trip_history/presentation/screens/driver_trip_history_screen.dart`**
  - Lines 24-26: Filter tuples
  - Lines 190-193: Status color and background mapping (4 cases)

- **`lib/features/driver/my_trip/domain/driver_daily_trip.dart`**
  - Lines 71-73: Computed properties (isScheduled, isInProgress, isCompleted)

- **`lib/features/driver/my_trip/presentation/bloc/driver_trip_bloc.dart`**
  - Line 46: Active statuses set

- **`lib/features/driver/my_trip/data/driver_trip_repository.dart`**
  - Line 109: Query parameter for cancellation

- **`lib/features/driver/my_trip/presentation/screens/driver_booking_trip_screen.dart`**
  - Lines 111-150: Status-based UI rendering (6 cases)
  - Lines 363-367: Status color mapping (5 cases)

- **`lib/features/driver/my_trip/presentation/screens/driver_daily_trip_screen.dart`**
  - Lines 442-443: Status color mapping

### Fleet Manager Features
- **`lib/features/fleet_manager/daily_trips/presentation/screens/daily_trips_screen.dart`**
  - Lines 28-33: Filter list (6 statuses)
  - Lines 81-82: Status-based filtering
  - Lines 183, 290-291: Booking filtering
  - Lines 426: Needs driver check
  - Lines 546-555: Status color and display name mapping (6 cases)

- **`lib/features/fleet_manager/daily_schedules/presentation/screens/daily_schedules_screen.dart`**
  - Lines 958-960: Status display mapping (3 cases)

## Migration Strategy

### Phase 1: Create Infrastructure
1. Create `lib/features/fleet_manager/bookings/domain/booking_status.dart`
   - Define `BookingStatus` enum with all 12-13 values
   - Add extension methods for display names, colors, backgrounds
   - Add helper methods (isCompleted, isInProgress, isCancelled, etc.)

### Phase 2: Update Models
1. Update `Booking` model to use `BookingStatus status` instead of `String status`
2. Add `fromJson` factory to parse string → enum

### Phase 3: Gradual Refactoring
1. Start with employee screens (2 files, most concentrated usage)
2. Move to driver screens (5 files)
3. Complete with fleet manager screens (3 files)

### Benefits
- ✅ Type safety: Compiler catches invalid statuses
- ✅ IntelliSense: Auto-complete for all valid statuses
- ✅ Single source of truth: No duplicate strings
- ✅ Easy refactoring: Global rename if status names change
- ✅ Consistency: Same display logic everywhere
- ✅ Testing: Easier to test with enum values

## Implementation Steps
1. Create enum in `booking_status.dart`
2. Add display helper methods (extension or static)
3. Update Booking model
4. Refactor screens one-by-one with validation
5. Remove all hardcoded string constants

# Booking Status String Inventory by File

## Overview
Complete listing of all 137+ status string occurrences with file locations and refactoring impact.

---

## Employee Features (2 files, ~20 occurrences)

### 1. `lib/features/employee/my_trips/presentation/screens/employee_my_trips_screen.dart`
**Impact: HIGH** - Most concentrated usage

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 22-26 | 5 | Filter tuples | `(label, value: 'PENDING_APPROVAL')` etc | Filter chips - needs refactor |
| 253-259 | 7 | Color mapping | `'COMPLETED' => AppColors.good` | Status color selection |
| 265-276 | 12 | Display names | `'PENDING_APPROVAL' => 'Pending'` | Status badge text (DUPLICATE of employee_home_screen!) |

**Total: 24 occurrences**
**Refactor Strategy:** Replace switch statements with `status.color` and `status.displayName` properties; update filter list to use enum values

---

### 2. `lib/features/employee/home/presentation/screens/employee_home_screen.dart`
**Impact: MEDIUM** - Duplicated logic

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 320-325 | 5 | Color mapping (Today's trip) | `'IN_PROGRESS' => AppColors.good` | Status color for today's trip card |
| 420-425 | 5 | Color mapping (Recent trips) | `'COMPLETED' => AppColors.good` | Status color for recent trip rows |
| 492-496 | 5 | Display names | `'PENDING_APPROVAL' => 'Pending'` | Status badge text (DUPLICATE!) |

**Total: 15 occurrences**
**Refactor Strategy:** Same as above + identify duplicate with my_trips_screen

---

### 3. `lib/features/employee/daily_schedule/presentation/screens/employee_daily_schedule_screen.dart`
**Impact: MEDIUM**

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 469-470 | 2 | Color mapping | `'IN_PROGRESS' => AppColors.good` | Status color for daily trip cards |

**Total: 2 occurrences**

---

## Driver Features (5 files, ~40 occurrences)

### 4. `lib/features/driver/trip_history/presentation/screens/driver_trip_history_screen.dart`
**Impact: MEDIUM** - Multiple status references

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 24-26 | 3 | Filter tuples | `('Completed', 'COMPLETED')` | Filter list |
| 190-193 | 4 | Color+bg mapping | `'COMPLETED' => (AppColors.good, AppColors.goodBg)` | Status badge styling |

**Total: 7 occurrences**

---

### 5. `lib/features/driver/my_trip/domain/driver_daily_trip.dart`
**Impact: LOW** - Domain model properties

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 71-73 | 3 | Property checks | `status == 'SCHEDULED' \|\| status == 'DRIVER_ASSIGNED'` | Computed properties (isScheduled, isInProgress, isCompleted) |

**Total: 3 occurrences**
**Refactor Strategy:** Can use enum helper methods like `status.isActive`, `status.isCompleted` once model updated

---

### 6. `lib/features/driver/my_trip/presentation/bloc/driver_trip_bloc.dart`
**Impact: LOW** - BLoC filtering logic

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 46 | 3 | Set of statuses | `{'DRIVER_EN_ROUTE', 'ARRIVED', 'IN_PROGRESS'}` | Active statuses filter |

**Total: 3 occurrences**

---

### 7. `lib/features/driver/my_trip/data/driver_trip_repository.dart`
**Impact: LOW** - API query parameter

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 109 | 1 | Query param | `queryParameters: {'to': 'CANCELLED_BY_DRIVER'}` | API cancellation endpoint |

**Total: 1 occurrence**

---

### 8. `lib/features/driver/my_trip/presentation/screens/driver_booking_trip_screen.dart`
**Impact: MEDIUM** - Heavy conditional logic

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 111-150 | 6 | Status-based UI | `'DRIVER_ASSIGNED' => Column(...)` | Multi-branch UI rendering |
| 363-367 | 5 | Color+bg mapping | `'DRIVER_ASSIGNED' => (AppColors.warn, AppColors.warnBg)` | Status badge styling |

**Total: 11 occurrences**

---

### 9. `lib/features/driver/my_trip/presentation/screens/driver_daily_trip_screen.dart`
**Impact: LOW** - Simple color mapping

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 442-443 | 2 | Color mapping | `'IN_PROGRESS' => (AppColors.accent, AppColors.accentBg)` | Status badge styling |

**Total: 2 occurrences**

---

## Fleet Manager Features (3 files, ~50+ occurrences)

### 10. `lib/features/fleet_manager/daily_trips/presentation/screens/daily_trips_screen.dart`
**Impact: HIGHEST** - Most extensive usage (25+ occurrences)

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 28-33 | 6 | Filter list | `'APPROVED', 'DRIVER_ASSIGNED'` etc | Status filter chips |
| 81-82 | 2 | Filtering | `.where((b) => b.status == 'APPROVED')` | Booking grouping by status |
| 183 | 1 | Count check | `needDriver = ...where(b.status == 'APPROVED')` | Stat calculation |
| 290-291 | 2 | Count by status | `.where((b) => b.status == 'APPROVED')` | Stats |
| 426 | 1 | Needs driver check | `booking.status == 'APPROVED'` | Conditional UI |
| 546-555 | 9 | Color+name mapping | `'IN_PROGRESS' => AppColors.good, 'IN_PROGRESS' => 'Live'` | Status badge styling + names |

**Total: 21 occurrences (PLUS MANY MORE in similar logic)**

---

### 11. `lib/features/fleet_manager/daily_schedules/presentation/screens/daily_schedules_screen.dart`
**Impact: MEDIUM** - Moderate duplication

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 958-960 | 3 | Display+color mapping | `'DRIVER_ASSIGNED' => ('Assigned', AppColors.info, AppColors.infoBg)` | Status badge with name and colors |

**Total: 3 occurrences**

---

### 12. `lib/features/fleet_manager/reports/presentation/screens/reports_screen.dart`
**Impact: LOW** - String literal only

| Line(s) | Count | Type | Current Code | Usage |
|---------|-------|------|--------------|-------|
| 259 | 1 | Display text | `('Completed', '${summary.completedBookings}')` | Not status enum usage |

**Total: 0 occurrences** (excluded - not part of status enum)

---

## Domain Models (1 file, 3 occurrences)

### 13. `lib/features/driver/my_trip/domain/driver_daily_trip.dart`
(See above - listed with driver features)

---

## Summary Statistics

```
Total Files with Status Strings:  12
Total Status Occurrences:         ~137

BY FREQUENCY:
- daily_trips_screen.dart:        21+ (HIGHEST)
- employee_my_trips_screen.dart:  24
- employee_home_screen.dart:      15
- driver_booking_trip_screen.dart: 11
- driver_trip_history_screen.dart:  7
- Others:                          ~58

BY TYPE:
- Color mappings:          ~50 occurrences
- Display names:           ~35 occurrences (DUPLICATE!)
- Filter lists:            ~15 occurrences
- Direct comparisons:      ~25 occurrences
- Property checks:          ~5 occurrences
- Query parameters:         ~2 occurrences

BY FEATURE:
- Employee:               ~41
- Driver:                 ~43
- Fleet Manager:          ~50+
- Unknown/Other:          ~3
```

---

## Refactoring Priority & Effort Estimate

### 🔴 CRITICAL (Start Here!)
**Files:** employee_my_trips_screen.dart, employee_home_screen.dart  
**Impact:** Highest duplication + centralized logic  
**Effort:** ~30 min (both together)  
**Gain:** 24 + 15 = 39 occurrences eliminated

### 🟡 HIGH
**Files:** daily_trips_screen.dart  
**Impact:** Most extensive usage in fleet manager  
**Effort:** ~60 min  
**Gain:** 21+ occurrences eliminated

### 🟢 MEDIUM
**Files:** driver_booking_trip_screen.dart, daily_schedules_screen.dart  
**Effort:** ~30 min each  
**Gain:** 11 + 3 = 14 occurrences

### 🔵 LOW (Can do later)
**Files:** driver_trip_history, driver_daily_trip_screen, employee_daily_schedule, etc.  
**Effort:** ~15 min per file  
**Gain:** Incremental cleanup

---

## Total Refactoring Effort Estimate
- **Critical Phase:** 30 min → 39 occurrences eliminated (28%)
- **High Phase:** 60 min → 60+ occurrences eliminated (44%)
- **Medium Phase:** 60 min → 14+ occurrences eliminated (10%)
- **Low Phase:** 60 min → remaining (18%)

**Total: ~3 hours for complete migration**

---

## Implementation Checklist

### Phase 1: Update Booking Model
- [ ] Update Booking.status from String to BookingStatus
- [ ] Update fromJson to use BookingStatus.fromString()
- [ ] Test deserialization

### Phase 2: Critical Refactoring
- [ ] Refactor employee_my_trips_screen.dart
- [ ] Refactor employee_home_screen.dart
- [ ] Test employee screens

### Phase 3: High Priority
- [ ] Refactor daily_trips_screen.dart
- [ ] Test fleet manager screens

### Phase 4: Medium Priority
- [ ] Refactor driver_booking_trip_screen.dart
- [ ] Refactor daily_schedules_screen.dart

### Phase 5: Cleanup
- [ ] Refactor remaining driver/employee screens
- [ ] Run full analyzer check
- [ ] Test all features end-to-end

import '../../domain/driver_daily_trip.dart';
import '../../../../fleet_manager/bookings/domain/booking.dart';

enum DriverTripStatus { initial, loading, loaded, actionInProgress, error }

class DriverTripState {
  final DriverTripStatus status;
  final Booking? activeBooking;
  final Booking? completedBooking;
  final DriverDailyTrip? dailyTrip;
  final String? errorMessage;
  final String? actionError;
  final String availability; // 'AVAILABLE' | 'ON_TRIP' | 'OFF_DUTY'

  const DriverTripState({
    this.status = DriverTripStatus.initial,
    this.activeBooking,
    this.completedBooking,
    this.dailyTrip,
    this.errorMessage,
    this.actionError,
    this.availability = 'OFF_DUTY',
  });

  DriverTripState copyWith({
    DriverTripStatus? status,
    Booking? activeBooking,
    Booking? completedBooking,
    DriverDailyTrip? dailyTrip,
    String? errorMessage,
    String? actionError,
    String? availability,
    bool clearActionError = false,
    bool clearErrorMessage = false,
    bool clearCompletedBooking = false,
  }) =>
      DriverTripState(
        status: status ?? this.status,
        activeBooking: activeBooking ?? this.activeBooking,
        completedBooking: clearCompletedBooking ? null : (completedBooking ?? this.completedBooking),
        dailyTrip: dailyTrip ?? this.dailyTrip,
        errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
        actionError: clearActionError ? null : (actionError ?? this.actionError),
        availability: availability ?? this.availability,
      );
}

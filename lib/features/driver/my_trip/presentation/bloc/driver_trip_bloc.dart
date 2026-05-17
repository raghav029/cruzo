import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/driver_trip_repo.dart';
import '../../../location/driver_location_service.dart';
import '../../../../../core/network/result.dart';
import '../../../../fleet_manager/bookings/domain/booking_status.dart';
import 'driver_trip_event.dart';
import 'driver_trip_state.dart';

class DriverTripBloc extends Bloc<DriverTripEvent, DriverTripState> {
  final DriverTripRepo _repo;
  final DriverLocationService _locationService;

  DriverTripBloc(this._repo, this._locationService)
    : super(const DriverTripState()) {
    on<DriverTripLoadRequested>(_onLoad);
    on<DriverTripStatusUpdated>(_onStatusUpdate);
    on<DriverTripBoardingOtpVerified>(_onBoardingOtpVerify);
    on<DriverTripDropOtpVerified>(_onDropOtpVerify);
    on<DriverDailyTripPassengerBoarded>(_onBoard);
    on<DriverDailyTripPassengerDropped>(_onDrop);
    on<DriverDailyTripPassengerNoShow>(_onNoShow);
    on<DriverDailyTripCompleted>(_onComplete);
    on<DriverDailyTripStarted>(_onStartDailyTrip);
    on<DriverTripCancelled>(_onCancelBooking);
    on<DriverAvailabilityUpdated>(_onAvailabilityUpdate);
  }

  Future<void> _onLoad(
    DriverTripLoadRequested event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.loading,
        clearErrorMessage: true,
        clearCompletedBooking: true,
      ),
    );
    final bookingRes = await _repo.getMyActiveTrip();
    final dailyRes = await _repo.getMyTodayDailyTrip();

    final bookingErr = bookingRes.errorOrNull;
    final dailyErr = dailyRes.errorOrNull;
    final hasError = bookingErr != null && dailyErr != null;

    final booking = bookingRes.valueOrNull;
    final meRes = await _repo.getMyAvailability();
    emit(
      state.copyWith(
        status: hasError ? DriverTripStatus.error : DriverTripStatus.loaded,
        activeBooking: booking,
        dailyTrip: dailyRes.valueOrNull,
        errorMessage: hasError ? (bookingErr) : null,
        availability: meRes.valueOrNull ?? state.availability,
      ),
    );

    // Start/stop location push based on active booking
    final activeStatuses = {
      BookingStatus.driverEnRoute,
      BookingStatus.arrived,
      BookingStatus.inProgress,
    };
    if (booking != null && activeStatuses.contains(booking.statusEnum)) {
      await _locationService.requestPermission();
      _locationService.start(booking.id);
    } else {
      _locationService.stop();
    }
  }

  Future<void> _onStatusUpdate(
    DriverTripStatusUpdated event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.updateStatus(event.bookingId, event.status);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onBoardingOtpVerify(
    DriverTripBoardingOtpVerified event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.verifyBoardingOtp(event.bookingId, event.otp);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onDropOtpVerify(
    DriverTripDropOtpVerified event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.verifyDropOtp(event.bookingId, event.otp);
    if (res.isSuccess) {
      _locationService.stop();
      emit(state.copyWith(
        status: DriverTripStatus.loaded,
        completedBooking: state.activeBooking,
        clearActionError: true,
      ));
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onBoard(
    DriverDailyTripPassengerBoarded event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.boardPassenger(
      event.tripId,
      event.passengerId,
      event.otp,
    );
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onDrop(
    DriverDailyTripPassengerDropped event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.dropPassenger(
      event.tripId,
      event.passengerId,
      event.otp,
    );
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onNoShow(
    DriverDailyTripPassengerNoShow event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.markNoShow(event.tripId, event.passengerId);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onComplete(
    DriverDailyTripCompleted event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.completeDailyTrip(event.tripId);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onStartDailyTrip(
    DriverDailyTripStarted event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.startDailyTrip(event.tripId);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onCancelBooking(
    DriverTripCancelled event,
    Emitter<DriverTripState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DriverTripStatus.actionInProgress,
        clearActionError: true,
      ),
    );
    final res = await _repo.cancelBooking(event.bookingId);
    if (res.isSuccess) {
      add(const DriverTripLoadRequested());
    } else {
      emit(
        state.copyWith(
          status: DriverTripStatus.loaded,
          actionError: res.errorOrNull,
        ),
      );
    }
  }

  Future<void> _onAvailabilityUpdate(
    DriverAvailabilityUpdated event,
    Emitter<DriverTripState> emit,
  ) async {
    final previous = state.availability;
    // Optimistic update
    emit(state.copyWith(availability: event.availability));
    final res = await _repo.updateAvailability(event.availability);
    if (res.isSuccess) {
      emit(state.copyWith(availability: res.valueOrNull ?? event.availability));
    } else {
      // Revert on failure
      emit(
        state.copyWith(availability: previous, actionError: res.errorOrNull),
      );
    }
  }
}

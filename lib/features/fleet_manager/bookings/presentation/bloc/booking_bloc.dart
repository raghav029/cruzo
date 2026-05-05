import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/booking_repo.dart';
import '../../domain/booking.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepo _repo;

  BookingBloc(this._repo) : super(BookingInitial()) {
    on<BookingLoadRequested>(_onLoad);
    on<BookingApproveRequested>(_onApprove);
    on<BookingRejectRequested>(_onReject);
    on<BookingAssignDriverRequested>(_onAssignDriver);
    on<BookingAutoAssignRequested>(_onAutoAssign);
    on<BookingCancelRequested>(_onCancel);
  }

  Future<void> _onLoad(
    BookingLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await _repo.list(status: event.statusFilter);
    switch (result) {
      case Success(:final value):
        emit(BookingLoaded(value, activeFilter: event.statusFilter));
      case Failure(:final message):
        emit(BookingError(message));
    }
  }

  Future<void> _onApprove(
    BookingApproveRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = _current();
    emit(BookingMutating(current, event.id));
    final result = await _repo.approve(event.id);
    _handleMutation(emit, result, current, 'Booking approved');
  }

  Future<void> _onReject(
    BookingRejectRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = _current();
    emit(BookingMutating(current, event.id));
    final result = await _repo.reject(event.id, reason: event.reason);
    _handleMutation(emit, result, current, 'Booking rejected');
  }

  Future<void> _onAssignDriver(
    BookingAssignDriverRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = _current();
    emit(BookingMutating(current, event.id));
    final result = await _repo.assignDriver(
      event.id,
      event.driverId,
      event.vehicleId,
    );
    _handleMutation(emit, result, current, 'Driver assigned successfully');
  }

  Future<void> _onAutoAssign(
    BookingAutoAssignRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = _current();
    emit(BookingMutating(current, event.id));
    final result = await _repo.autoAssign(event.id);
    _handleMutation(emit, result, current, 'Driver auto-assigned');
  }

  Future<void> _onCancel(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    final current = _current();
    emit(BookingMutating(current, event.id));
    final result = await _repo.cancel(event.id, reason: event.reason);
    _handleMutation(emit, result, current, 'Booking cancelled');
  }

  void _handleMutation(
    Emitter<BookingState> emit,
    Result<Booking> result,
    List<Booking> current,
    String successMsg,
  ) {
    switch (result) {
      case Success(:final value):
        final updated = current
            .map((b) => b.id == value.id ? value : b)
            .toList();
        emit(BookingMutationSuccess(updated, successMsg));
      case Failure(:final message):
        emit(BookingMutationError(current, message));
    }
  }

  List<Booking> _current() {
    final s = state;
    if (s is BookingLoaded) return s.bookings;
    if (s is BookingMutating) return s.bookings;
    if (s is BookingMutationSuccess) return s.bookings;
    if (s is BookingMutationError) return s.bookings;
    return [];
  }
}

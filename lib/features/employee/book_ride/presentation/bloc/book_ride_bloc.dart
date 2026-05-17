import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cruzo/core/network/result.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking_repo.dart';
import 'book_ride_event.dart';
import 'book_ride_state.dart';

class BookRideBloc extends Bloc<BookRideEvent, BookRideState> {
  final BookingRepo _repo;

  BookRideBloc(this._repo) : super(const BookRideInitial()) {
    on<BookRideSubmitted>(_onSubmit);
    on<BookRideReset>((_, emit) => emit(const BookRideInitial()));
  }

  Future<void> _onSubmit(
    BookRideSubmitted event,
    Emitter<BookRideState> emit,
  ) async {
    emit(const BookRideSubmitting());
    final result = await _repo.create(
      corporateClientId: event.corporateClientId,
      pickupAddress: event.pickupAddress,
      dropAddress: event.dropAddress,
      vehicleType: event.vehicleType,
      scheduledAt: event.scheduledAt.toUtc().toIso8601String(),
      notes: event.notes,
    );
    switch (result) {
      case Success(:final value):
        emit(BookRideSuccess(value));
      case Failure(:final message):
        emit(BookRideFailure(message));
    }
  }
}

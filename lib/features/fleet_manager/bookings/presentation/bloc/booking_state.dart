import '../../domain/booking.dart';

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  final String? activeFilter;
  const BookingLoaded(this.bookings, {this.activeFilter});
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}

class BookingMutating extends BookingState {
  final List<Booking> bookings;
  final String bookingId;
  const BookingMutating(this.bookings, this.bookingId);
}

class BookingMutationSuccess extends BookingState {
  final List<Booking> bookings;
  final String message;
  const BookingMutationSuccess(this.bookings, this.message);
}

class BookingMutationError extends BookingState {
  final List<Booking> bookings;
  final String message;
  const BookingMutationError(this.bookings, this.message);
}

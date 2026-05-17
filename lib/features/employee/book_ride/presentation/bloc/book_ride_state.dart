import 'package:equatable/equatable.dart';
import 'package:cruzo/features/fleet_manager/bookings/domain/booking.dart';

abstract class BookRideState extends Equatable {
  const BookRideState();
  @override
  List<Object?> get props => [];
}

class BookRideInitial extends BookRideState {
  const BookRideInitial();
}

class BookRideSubmitting extends BookRideState {
  const BookRideSubmitting();
}

class BookRideSuccess extends BookRideState {
  final Booking booking;
  const BookRideSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookRideFailure extends BookRideState {
  final String message;
  const BookRideFailure(this.message);
  @override
  List<Object?> get props => [message];
}

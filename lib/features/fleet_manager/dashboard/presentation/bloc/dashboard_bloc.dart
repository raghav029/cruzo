import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/dashboard_repo.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo _repo;

  DashboardBloc(this._repo) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) emit(const DashboardLoading());
    final result = await _repo.getSummary();
    switch (result) {
      case Success(:final value):
        emit(DashboardLoaded(value));
      case Failure(:final message):
        emit(DashboardError(message));
    }
  }
}

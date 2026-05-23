import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_state.dart';

extension CurrentUser on BuildContext {
  AuthAuthenticated? get authUser {
    final state = read<AuthBloc>().state;
    return state is AuthAuthenticated ? state : null;
  }

  AppRole get currentRole => authUser?.role ?? AppRole.unknown;
  String get currentUserId => authUser?.userId ?? '';
  String get currentUserName => authUser?.name ?? '';

  bool get isFleetManager => currentRole == AppRole.fleetManager;
  bool get isCorporateAdmin => currentRole == AppRole.corporateAdmin;
  bool get isEmployee => currentRole == AppRole.employee;
  bool get isDriver => currentRole == AppRole.driver;
  bool get isSuperAdmin => currentRole == AppRole.superAdmin;
}

extension WatchCurrentUser on BuildContext {
  AuthAuthenticated? get watchAuthUser {
    final state = watch<AuthBloc>().state;
    return state is AuthAuthenticated ? state : null;
  }

  AppRole get watchCurrentRole => watchAuthUser?.role ?? AppRole.unknown;
  bool get watchIsFleetManager => watchCurrentRole == AppRole.fleetManager;
  bool get watchIsCorporateAdmin => watchCurrentRole == AppRole.corporateAdmin;
  bool get watchIsEmployee => watchCurrentRole == AppRole.employee;
  bool get watchIsDriver => watchCurrentRole == AppRole.driver;
}

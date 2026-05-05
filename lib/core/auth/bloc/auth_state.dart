import 'package:equatable/equatable.dart';

enum AppRole { fleetManager, employee, driver, superAdmin, corporateAdmin, unknown }

AppRole roleFromString(String role) => switch (role) {
      'ROLE_FLEET_MANAGER' => AppRole.fleetManager,
      'ROLE_EMPLOYEE' => AppRole.employee,
      'ROLE_DRIVER' => AppRole.driver,
      'ROLE_SUPER_ADMIN' => AppRole.superAdmin,
      'ROLE_CORPORATE_ADMIN' => AppRole.corporateAdmin,
      _ => AppRole.unknown,
    };

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String token;
  final AppRole role;
  final String userId;
  final String name;
  const AuthAuthenticated({
    required this.token,
    required this.role,
    required this.userId,
    required this.name,
  });
  @override
  List<Object?> get props => [token, role, userId, name];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

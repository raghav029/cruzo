abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  static const appRole = String.fromEnvironment(
    'APP_ROLE',
    defaultValue: 'employee',
  );
}

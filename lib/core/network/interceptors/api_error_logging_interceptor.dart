class ApiErrorLoggingInterceptor {
  ApiErrorLoggingInterceptor._();

  static void logApiClientSideError(String url, String message) {
    // Replace with your telemetry/logging integration.
    // Kept intentionally minimal to avoid depending on analytics packages here.
    // Example: Sentry.captureMessage('API client error: $url — $message');
    // For now just print.
    // ignore: avoid_print
    print('[API CLIENT ERROR] $url — $message');
  }

  static void logApiParsingFailure(String url, String message) {
    // ignore: avoid_print
    print('[API PARSING FAILURE] $url — $message');
  }
}

final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'OMNICONNECT_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'OMNICONNECT_API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static const String googleClientId = String.fromEnvironment(
    'OMNICONNECT_GOOGLE_CLIENT_ID',
    defaultValue: '1050327728354-u3d9ptf6ms70kufgvhv026ueoe161kg8.apps.googleusercontent.com',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

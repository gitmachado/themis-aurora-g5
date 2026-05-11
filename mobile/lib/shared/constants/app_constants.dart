final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'THEMIS_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const String googleClientId = String.fromEnvironment(
    'THEMIS_GOOGLE_CLIENT_ID',
    defaultValue:
        '726117555634-alkikmg6f84hlkl9lkg008jqf1v24d9j.apps.googleusercontent.com',
  );

  static const String officeWhatsApp = String.fromEnvironment(
    'THEMIS_OFFICE_WHATSAPP',
    defaultValue: '558487922092',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

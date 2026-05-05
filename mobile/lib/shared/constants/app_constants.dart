final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'THEMIS_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const String googleClientId = String.fromEnvironment(
    'THEMIS_GOOGLE_CLIENT_ID',
    defaultValue:
        '713885920352-n4ahv30vrjtp1548g2u9os3ui1t8lbci.apps.googleusercontent.com',
  );

  static const String officeWhatsApp = String.fromEnvironment(
    'THEMIS_OFFICE_WHATSAPP',
    defaultValue: '558487922092',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

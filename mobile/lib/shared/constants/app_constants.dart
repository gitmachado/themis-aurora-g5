final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'THEMIS_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const String googleClientId =
      '726117555634-v9p8rcatfaghfnftuar0mpc3qkr1qc2i.apps.googleusercontent.com';

  static const String officeWhatsApp = String.fromEnvironment(
    'THEMIS_OFFICE_WHATSAPP',
    defaultValue: '5584887922092',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

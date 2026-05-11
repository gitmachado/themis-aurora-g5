final class AppConstants {
  const AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'THEMIS_API_BASE_URL',
    defaultValue: 'https://embassy-stolen-loc-construction.trycloudflare.com/api/v1',
  );

  static const String googleClientId =
      '726117555634-v9p8rcatfaghfnftuar0mpc3qkr1qc2i.apps.googleusercontent.com';

  static const String officeWhatsApp = String.fromEnvironment(
    'THEMIS_OFFICE_WHATSAPP',
    defaultValue: '558487922092',
  );

  static const Duration requestConnectTimeout = Duration(seconds: 15);
  static const Duration requestReceiveTimeout = Duration(seconds: 20);
}

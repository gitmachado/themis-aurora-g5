final class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'OMNICONNECT_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
}

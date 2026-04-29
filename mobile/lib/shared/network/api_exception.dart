enum ApiExceptionType { server, network, auth }

final class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiExceptionType type;

  const ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiExceptionType.server,
  });

  @override
  String toString() => message;
}

import 'package:mobile/shared/network/api_client.dart';
import 'package:mobile/shared/network/token_storage.dart';

final class ApiCall {
  final String method;
  final String path;
  final Map<String, dynamic>? data;
  final String? filePath;
  final String? fileName;
  final String? fileField;

  const ApiCall(
    this.method,
    this.path, [
    this.data,
    this.filePath,
    this.fileName,
    this.fileField,
  ]);
}

final class FakeApiClient implements ApiClient {
  final List<ApiCall> calls = [];
  final Map<String, Map<String, dynamic>> jsonResponses = {};
  final Map<String, List<dynamic>> listResponses = {};

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    calls.add(ApiCall('GET', path));
    return jsonResponses['GET $path'] ?? <String, dynamic>{};
  }

  @override
  Future<List<dynamic>> getList(String path) async {
    calls.add(ApiCall('GET', path));
    return listResponses['GET $path'] ?? <dynamic>[];
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    calls.add(ApiCall('POST', path, data));
    return jsonResponses['POST $path'] ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    String? fileName,
    Map<String, dynamic>? fields,
  }) async {
    calls.add(
      ApiCall('POST_MULTIPART', path, fields, filePath, fileName, fileField),
    );
    return jsonResponses['POST_MULTIPART $path'] ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    calls.add(ApiCall('PATCH', path, data));
    return jsonResponses['PATCH $path'] ?? <String, dynamic>{};
  }

  @override
  Future<void> postVoid(String path) async {
    calls.add(ApiCall('POST', path));
  }

  @override
  Future<void> deleteVoid(String path) async {
    calls.add(ApiCall('DELETE', path));
  }

  @override
  Future<String> getDocumentAccessUrl(String documentId) async {
    final path = '/documents/$documentId/access-url';
    calls.add(ApiCall('GET', path));
    final url = jsonResponses['GET $path']?['url'];
    if (url is String && url.isNotEmpty) {
      return url;
    }

    return buildDocumentUrl(documentId);
  }

  @override
  String buildDocumentUrl(String filename) {
    final normalized = filename.replaceAll('\\', '/');
    final resolved = normalized
        .split('/')
        .where((part) => part.isNotEmpty)
        .last;
    return 'http://localhost:3000/api/v1/documents/view/$resolved';
  }
}

final class FakeTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> clearToken() async {
    token = null;
  }
}

import 'dart:async';
import 'package:mobile/shared/network/api_client.dart';
import 'package:mobile/shared/network/token_storage.dart';
import 'package:mobile/shared/network/websocket_client.dart';

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

class FakeApiClient implements ApiClient {
  static const _baseUrl = 'http://localhost:3000/api/v1';

  final List<ApiCall> calls = [];
  final Map<String, Map<String, dynamic>> jsonResponses = {};
  final Map<String, List<dynamic>> listResponses = {};

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    calls.add(ApiCall('GET', path));
    final response = jsonResponses['GET $path'];
    if (response == null) {
      throw Exception(
        'FakeApiClient: GET $path nao configurado. Adicione-o ao fake para evitar TypeError.',
      );
    }
    return response;
  }

  @override
  Future<List<dynamic>> getList(String path) async {
    calls.add(ApiCall('GET', path));
    final response = listResponses['GET $path'];
    if (response == null) {
      throw Exception('FakeApiClient: GET $path (list) nao configurado.');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    calls.add(ApiCall('POST', path, data));
    final response = jsonResponses['POST $path'];
    if (response == null) {
      throw Exception('FakeApiClient: POST $path nao configurado.');
    }
    return response;
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
    final response = jsonResponses['PATCH $path'];
    if (response == null) {
      throw Exception('FakeApiClient: PATCH $path nao configurado.');
    }
    return response;
  }

  @override
  Future<void> postVoid(String path) async {
    calls.add(ApiCall('POST', path));
  }

  @override
  Future<void> deleteVoid(String path, {Map<String, dynamic>? data}) async {
    calls.add(ApiCall('DELETE', path, data));
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
    return '$_baseUrl/documents/view/$resolved';
  }

  @override
  String buildAbsoluteUrl(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return urlOrPath;
    }

    return Uri.parse(_baseUrl).resolve(urlOrPath).toString();
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

class FakeWebSocketClient implements WebSocketClient {
  final _controller = StreamController<WebSocketEvent>.broadcast();

  @override
  Stream<WebSocketEvent> get events => _controller.stream;

  @override
  bool get isConnected => false;

  @override
  void connect() {}

  @override
  void disconnect() {}

  @override
  void joinChat(String whatsappNumber) {}

  @override
  void leaveChat(String whatsappNumber) {}

  void emit(WebSocketEvent event) => _controller.add(event);
}

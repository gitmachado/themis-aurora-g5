import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({
    Dio? dio,
    TokenStorage? tokenStorage,
    String baseUrl = AppConstants.apiBaseUrl,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: AppConstants.requestConnectTimeout,
               receiveTimeout: AppConstants.requestReceiveTimeout,
               headers: const {'Accept': 'application/json'},
             ),
           ),
       _tokenStorage = tokenStorage ?? const SecureTokenStorage() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _send(() => _dio.get<Object?>(path));
    return _asMap(response.data);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _send(() => _dio.get<Object?>(path));
    final data = response.data;
    if (data is List) return data;
    throw const ApiException('Resposta inesperada do servidor');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _send(() => _dio.post<Object?>(path, data: data));
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    String? fileName,
    Map<String, dynamic>? fields,
    void Function(int count, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      ...?fields,
      fileField: await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _send(
      () => _dio.post<Object?>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      ),
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _send(() => _dio.patch<Object?>(path, data: data));
    if (response.statusCode == 204 || response.data == null) {
      return <String, dynamic>{};
    }
    return _asMap(response.data);
  }

  Future<void> postVoid(String path, {Map<String, dynamic>? data}) async {
    await _send(() => _dio.post<Object?>(path, data: data));
  }

  Future<void> deleteVoid(String path, {Map<String, dynamic>? data}) async {
    await _send(() => _dio.delete<Object?>(path, data: data));
  }

  Future<String> getDocumentAccessUrl(String documentId) async {
    final json = await getJson('/documents/$documentId/access-url');
    final url = json['url'];
    if (url is! String || url.isEmpty) {
      throw const ApiException('URL do arquivo nao retornada pelo servidor');
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return buildDocumentUrl(url);
  }

  String buildDocumentUrl(String filenameOrUrl) {
    if (filenameOrUrl.startsWith('http://') ||
        filenameOrUrl.startsWith('https://')) {
      return filenameOrUrl;
    }

    final normalized = filenameOrUrl.replaceAll('\\', '/');
    final filename = normalized
        .split('/')
        .where((part) => part.isNotEmpty)
        .last;
    return '${_dio.options.baseUrl}/documents/view/${Uri.encodeComponent(filename)}';
  }

  String buildAbsoluteUrl(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return urlOrPath;
    }

    return Uri.parse(_dio.options.baseUrl).resolve(urlOrPath).toString();
  }

  Future<void> downloadFile(String url, String savePath) async {
    await _send(() => _dio.download(url, savePath));
  }

  Future<Response<Object?>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Resposta inesperada do servidor');
  }

  ApiException _mapDioException(DioException error) {
    final data = error.response?.data;
    final statusCode = error.response?.statusCode;
    String message = 'Nao foi possivel falar com o servidor';

    if (data is Map) {
      final serverMessage = data['message'] ?? data['error'];
      if (serverMessage is String && serverMessage.isNotEmpty) {
        message = serverMessage;
      }
    } else if (error.message != null && error.message!.isNotEmpty) {
      message = error.message!;
    }

    return ApiException(
      message,
      statusCode: statusCode,
      type: _apiExceptionType(error, statusCode),
    );
  }

  ApiExceptionType _apiExceptionType(DioException error, int? statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return ApiExceptionType.auth;
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => ApiExceptionType.network,
      _ => ApiExceptionType.server,
    };
  }
}

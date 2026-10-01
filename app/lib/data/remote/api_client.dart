import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  ApiException({required this.code, required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException [$code] ($statusCode): $message';
}

class ApiClient {
  String baseUrl = AppConstants.defaultBaseUrl;
  String? authToken;

  ApiClient({String? customBaseUrl, this.authToken}) {
    if (customBaseUrl != null) {
      baseUrl = customBaseUrl;
    }
  }

  void setToken(String? token) {
    authToken = token;
  }

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    Uri uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    try {
      final res = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 8));
      return _handleResponse(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http.post(
        uri,
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 12));
      return _handleResponse(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http.patch(
        uri,
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 10));
      return _handleResponse(res);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response res) {
    dynamic data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      data = res.body;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final errorObj = data is Map ? data['error'] : null;
    final code = errorObj != null ? errorObj['code'] : 'HTTP_${res.statusCode}';
    final message = errorObj != null ? errorObj['message'] : 'Request failed with status ${res.statusCode}';

    throw ApiException(code: code ?? 'ERROR', message: message ?? 'Unknown error', statusCode: res.statusCode);
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(code: 'NETWORK_OFFLINE', message: 'Network offline or server unreachable.', statusCode: 0);
  }
}

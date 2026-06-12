import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? authToken,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _httpClient.get(
      _uri(path, queryParameters: queryParameters),
      headers: _headers(authToken: authToken),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: _headers(authToken: authToken),
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    String? authToken,
  }) async {
    final response = await _httpClient.put(
      _uri(path),
      headers: _headers(authToken: authToken),
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    String? authToken,
  }) async {
    final response = await _httpClient.delete(
      _uri(path),
      headers: _headers(authToken: authToken),
    );

    return _decodeResponse(response);
  }

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBaseUrl = AppConfig.apiBaseUrl.endsWith('/')
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$normalizedBaseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.isEmpty ?? true
          ? null
          : queryParameters,
    );
  }

  Map<String, String> _headers({String? authToken}) {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decodedBody = response.body.isEmpty
        ? null
        : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      return <String, dynamic>{};
    }

    var message = 'Request failed';

    if (decodedBody is Map<String, dynamic>) {
      final responseMessage = decodedBody['message'];
      final errors = decodedBody['errors'];

      if (responseMessage is String) {
        message = responseMessage;
      }

      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;

        if (firstError is Map<String, dynamic> &&
            firstError['message'] is String) {
          message = firstError['message'] as String;
        }
      }
    }

    throw ApiException(message, statusCode: response.statusCode);
  }
}

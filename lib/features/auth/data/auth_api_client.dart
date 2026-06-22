import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_models.dart';

class AuthApiClient {
  AuthApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const String _genericServerError = 'Something went wrong. Please try again.';

  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  String get _baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api')) {
        return '$configuredBaseUrl/mobile/auth';
      }

      return '$configuredBaseUrl/api/mobile/auth';
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api/mobile/auth';
    }

    return '$configuredBaseUrl/api/mobile/auth';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  String _extractErrorMessage(Map<String, dynamic> payload, int statusCode) {
    if (statusCode >= 500) {
      return _genericServerError;
    }

    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return _genericServerError;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path);
    print('DEBUG API: POST $uri');
    print('DEBUG API: Body: $body');

    try {
      final response = await _httpClient.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('DEBUG API: Status code: ${response.statusCode}');
      print('DEBUG API: Response body: ${response.body}');

      final payload = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = _extractErrorMessage(payload, response.statusCode);
        print('DEBUG API: Error - $message');
        throw AuthApiException(message);
      }

      return payload;
    } catch (error) {
      print('DEBUG API: Request failed with error: $error');
      print('DEBUG API: Error type: ${error.runtimeType}');
      rethrow;
    }
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LearningApiClient {
  LearningApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  String get _baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/v1/content/mobile')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api/v1/content')) {
        return '$configuredBaseUrl/mobile';
      }

      if (configuredBaseUrl.endsWith('/api/v1')) {
        return '$configuredBaseUrl/content/mobile';
      }

      if (configuredBaseUrl.endsWith('/api')) {
        return '$configuredBaseUrl/v1/content/mobile';
      }

      return '$configuredBaseUrl/api/v1/content/mobile';
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api/v1/content/mobile';
    }

    return '$configuredBaseUrl/api/v1/content/mobile';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _httpClient.get(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
    );

    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw LearningApiException(message);
    }

    return payload;
  }
}

class LearningApiException implements Exception {
  const LearningApiException(this.message);

  final String message;

  @override
  String toString() => 'LearningApiException: $message';
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MentorApiClient {
  MentorApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  String get _baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/v1/professionals')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
        return configuredBaseUrl.replaceFirst(
          RegExp(r'/api/mobile/auth$'),
          '/api/v1/professionals',
        );
      }

      if (configuredBaseUrl.endsWith('/api/v1')) {
        return '$configuredBaseUrl/professionals';
      }

      if (configuredBaseUrl.endsWith('/api')) {
        return '$configuredBaseUrl/v1/professionals';
      }

      return '$configuredBaseUrl/api/v1/professionals';
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api/v1/professionals';
    }

    return '$configuredBaseUrl/api/v1/professionals';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _httpClient.get(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
    );

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw MentorApiException(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List<dynamic>) {
      return {'data': decoded};
    }

    throw const MentorApiException('Unexpected response format');
  }
}

class MentorApiException implements Exception {
  const MentorApiException(this.message);

  final String message;

  @override
  String toString() => 'MentorApiException: $message';
}

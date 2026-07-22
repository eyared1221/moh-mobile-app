import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiskAssessmentApiClient {
  RiskAssessmentApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  String get _baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/v1/assessments')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
        return configuredBaseUrl.replaceFirst(
          RegExp(r'/api/mobile/auth$'),
          '/api/v1/assessments',
        );
      }

      if (configuredBaseUrl.endsWith('/api/v1')) {
        return '$configuredBaseUrl/assessments';
      }

      if (configuredBaseUrl.endsWith('/api')) {
        return '$configuredBaseUrl/v1/assessments';
      }

      return '$configuredBaseUrl/api/v1/assessments';
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api/v1/assessments';
    }

    return '$configuredBaseUrl/api/v1/assessments';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  String get _mobileAuthBaseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/mobile/auth')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api/v1/assessments')) {
        return configuredBaseUrl.replaceFirst(
          RegExp(r'/api/v1/assessments$'),
          '/api/mobile/auth',
        );
      }

      if (configuredBaseUrl.endsWith('/api/v1')) {
        return configuredBaseUrl.replaceFirst(RegExp(r'/api/v1$'), '/api/mobile/auth');
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

  Uri _mobileAuthUri(String path) => Uri.parse('$_mobileAuthBaseUrl$path');

  Future<Map<String, String>> _authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      throw const RiskAssessmentApiException('You need to sign in again to continue.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

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
      throw RiskAssessmentApiException(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List<dynamic>) {
      return {'data': decoded};
    }

    throw const RiskAssessmentApiException('Unexpected response format');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
    {
      Map<String, String>? headers,
    }
  ) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw RiskAssessmentApiException(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const RiskAssessmentApiException('Unexpected response format');
  }

  Future<Map<String, dynamic>> postAuthorized(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.post(
      _uri(path),
      headers: await _authorizedHeaders(),
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw RiskAssessmentApiException(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const RiskAssessmentApiException('Unexpected response format');
  }

  Future<Map<String, dynamic>> postAuthorizedToMobileAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.post(
      _mobileAuthUri(path),
      headers: await _authorizedHeaders(),
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw RiskAssessmentApiException(message);
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const RiskAssessmentApiException('Unexpected response format');
  }
}

class RiskAssessmentApiException implements Exception {
  const RiskAssessmentApiException(this.message);

  final String message;

  @override
  String toString() => 'RiskAssessmentApiException: $message';
}

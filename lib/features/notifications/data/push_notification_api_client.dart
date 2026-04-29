import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationApiException implements Exception {
  final String message;

  const PushNotificationApiException(this.message);

  @override
  String toString() => message;
}

class PushNotificationApiClient {
  PushNotificationApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

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

  Future<Map<String, String>> _authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      throw const PushNotificationApiException(
        'You need to sign in again before enabling push notifications.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> registerPushToken(Map<String, dynamic> body) async {
    final response = await _httpClient.post(
      _uri('/push-token'),
      headers: await _authorizedHeaders(),
      body: jsonEncode(body),
    );

    _decodeResponse(response);
  }

  Future<void> deletePushToken(String token) async {
    final response = await _httpClient.delete(
      _uri('/push-token'),
      headers: await _authorizedHeaders(),
      body: jsonEncode({'token': token}),
    );

    _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw PushNotificationApiException(message);
    }

    return payload;
  }
}

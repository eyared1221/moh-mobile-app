import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/faq_item.dart';

class FaqApiClient {
  FaqApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'MOBILE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  String get _baseUrl {
    final configuredBaseUrl = _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

    if (const bool.hasEnvironment('MOBILE_API_BASE_URL')) {
      if (configuredBaseUrl.endsWith('/api/v1/faqs')) {
        return configuredBaseUrl;
      }

      if (configuredBaseUrl.endsWith('/api/v1')) {
        return '$configuredBaseUrl/faqs';
      }

      if (configuredBaseUrl.endsWith('/api')) {
        return '$configuredBaseUrl/v1/faqs';
      }

      return '$configuredBaseUrl/api/v1/faqs';
    }

    if (kIsWeb) {
      return 'http://localhost:4000/api/v1/faqs';
    }

    return '$configuredBaseUrl/api/v1/faqs';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<FaqItem>> fetchFaqs() async {
    final response = await _httpClient.get(
      _uri(''),
      headers: const {'Content-Type': 'application/json'},
    );

    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      final error = payload['error'];
      final message = error is Map<String, dynamic>
          ? error['message'] as String? ?? 'Request failed'
          : payload['message'] as String? ?? 'Request failed';
      throw FaqApiException(message);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FaqApiException('Unexpected response format');
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const FaqApiException('Unexpected FAQ payload');
    }

    return data
        .whereType<Map>()
        .map((item) => FaqItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.question.isNotEmpty && item.answer.isNotEmpty)
        .toList();
  }
}

class FaqApiException implements Exception {
  const FaqApiException(this.message);

  final String message;

  @override
  String toString() => 'FaqApiException: $message';
}

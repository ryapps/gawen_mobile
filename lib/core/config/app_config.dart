import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  AppConfig._();

  static const _compileTimeBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _defaultBaseUrl = 'http://localhost:3000';
  static String _baseUrl = _compileTimeBaseUrl.isEmpty
      ? _defaultBaseUrl
      : _compileTimeBaseUrl;

  static String get baseUrl => _baseUrl;

  static Future<void> load() async {
    final contents = await rootBundle.loadString('.env.json');
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('.env.json harus berisi object JSON.');
    }

    final configuredBaseUrl = decoded['API_BASE_URL'];
    if (configuredBaseUrl is! String || configuredBaseUrl.trim().isEmpty) {
      throw const FormatException(
        'API_BASE_URL harus diisi sebagai URL pada .env.json.',
      );
    }

    final baseUrl =
        (_compileTimeBaseUrl.isEmpty ? configuredBaseUrl : _compileTimeBaseUrl)
            .trim();
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('API_BASE_URL pada .env.json tidak valid.');
    }

    _baseUrl = baseUrl;
  }
}

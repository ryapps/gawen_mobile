import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggingInterceptor extends Interceptor {
  static final _sensitiveKey = RegExp(
    r'password|passphrase|token|authorization|cookie|secret|api.?key|access.?key|credential|business.?code|hash',
    caseSensitive: false,
  );
  static final _opaqueToken = RegExp(r'\b[A-Za-z0-9_-]{43,64}\b');
  static final _jwt = RegExp(
    r'\beyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b',
  );
  static const _maxLineLength = 900;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _write('REQUEST', '${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    final body = _encodeBody(response.data);
    _write(
      'RESPONSE',
      '${response.statusCode ?? '-'} ${request.method} '
          '${request.uri.path} body=$body',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final response = err.response;
    final status = response?.statusCode?.toString() ?? 'no status';
    final body = response == null ? '' : ' body=${_encodeBody(response.data)}';
    _write(
      'ERROR',
      '$status ${request.method} '
          '${request.uri.path} '
          'type=${err.type.name}$body',
    );
    handler.next(err);
  }

  void _write(String event, String details) {
    if (!kDebugMode) return;
    final line = '[API] $event $details';
    for (var start = 0; start < line.length; start += _maxLineLength) {
      final end = (start + _maxLineLength).clamp(0, line.length);
      debugPrint(line.substring(start, end));
    }
  }

  String _encodeBody(Object? value) {
    final safeValue = _redact(value);
    final encoded = jsonEncode(safeValue);
    if (encoded.length <= 12000) return encoded;
    return '${encoded.substring(0, 12000)}… [truncated]';
  }

  Object? _redact(Object? value, [String? key]) {
    if (key != null && _sensitiveKey.hasMatch(key)) return '[REDACTED]';
    if (value is Map) {
      return value.map(
        (entryKey, entryValue) => MapEntry(
          entryKey.toString(),
          _redact(entryValue, entryKey.toString()),
        ),
      );
    }
    if (value is List<int>) return '<binary response: ${value.length} bytes>';
    if (value is Iterable) {
      return value.map((entry) => _redact(entry)).toList(growable: false);
    }
    if (value is String) {
      final trimmed = value.trimLeft();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return _redact(jsonDecode(value));
        } on FormatException {
          return _redactString(value);
        }
      }
      return _redactString(value);
    }
    if (value == null || value is num || value is bool) return value;
    return '<${value.runtimeType}>';
  }

  String _redactString(String value) => value
      .replaceAll(_jwt, '[REDACTED]')
      .replaceAll(_opaqueToken, '[REDACTED]');
}

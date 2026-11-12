import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class SessionExpiredFailure extends ApiFailure {
  const SessionExpiredFailure()
    : super('Sesi berakhir. Silakan masuk kembali.');
}

String dioErrorMessage(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'Server membutuhkan waktu terlalu lama untuk merespons. Coba lagi.';
  }
  if (error.type == DioExceptionType.connectionError) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  final body = error.response?.data;
  final statusCode = error.response?.statusCode;
  if (statusCode != null && statusCode >= 500) {
    return 'Terjadi masalah pada server. Silakan coba lagi.';
  }
  if (body is Map<String, dynamic> && body['message'] is String) {
    final message = friendlyErrorMessage(body['message'] as String);
    final details = body['details'];
    if (details is List) {
      final issues = details
          .whereType<Map<String, dynamic>>()
          .map((issue) {
            final path = issue['path'];
            final description = issue['message'];
            if (path is! String || description is! String) return null;
            return '$path: $description';
          })
          .whereType<String>()
          .toList(growable: false);
      if (issues.isNotEmpty && message != _unknownErrorMessage) {
        return '$message ${issues.join('; ')}';
      }
    }
    if (message != _unknownErrorMessage) return message;
  }
  switch (statusCode) {
    case 401:
      return 'Sesi Anda telah berakhir. Silakan masuk kembali.';
    case 403:
      return 'Anda tidak memiliki akses untuk melakukan tindakan ini.';
    case 404:
      return 'Data yang diminta tidak ditemukan.';
  }
  return _unknownErrorMessage;
}

const _unknownErrorMessage = 'Terjadi kesalahan. Silakan coba lagi.';

String _friendlyMessage(String message) {
  final technicalMessage = RegExp(
    r'\b(DioException|SocketException|FormatException|Status Code|stack trace|Internal Server Error|TypeError|Exception|PrismaClientKnownRequestError|SQLSTATE|Request failed|status code|Unauthorized|Forbidden|Not Found|Unknown Error|Network Error|ECONNRESET|ECONNREFUSED|ETIMEDOUT|ENOTFOUND|Database|SQL)\b|^\s*<(?:!doctype|html)',
    caseSensitive: false,
  );
  return technicalMessage.hasMatch(message) ? _unknownErrorMessage : message;
}

String friendlyErrorMessage(String message) {
  final normalized = message
      .replaceFirst(RegExp(r'^(Bad state:|Exception:)\s*'), '')
      .trim();
  return _friendlyMessage(normalized);
}

Future<T> executeApiRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw ApiFailure(dioErrorMessage(error));
  } on FormatException {
    throw const ApiFailure(_unknownErrorMessage);
  } on PlatformException {
    throw const ApiFailure('Penyimpanan sesi aman tidak tersedia.');
  }
}

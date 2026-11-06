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
    return 'Koneksi terlalu lama. Periksa jaringanmu, lalu coba lagi.';
  }
  if (error.type == DioExceptionType.connectionError) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.';
  }
  final body = error.response?.data;
  if (body is Map<String, dynamic> && body['message'] is String) {
    final message = body['message'] as String;
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
      if (issues.isNotEmpty) return '$message ${issues.join('; ')}';
    }
    return message;
  }
  final statusCode = error.response?.statusCode;
  if (statusCode != null && statusCode >= 500) {
    return 'Server sedang bermasalah. Coba lagi nanti.';
  }
  return 'Permintaan tidak dapat diproses. Periksa data dan coba lagi.';
}

Future<T> executeApiRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw ApiFailure(dioErrorMessage(error));
  } on FormatException catch (error) {
    throw ApiFailure(error.message);
  } on PlatformException {
    throw const ApiFailure('Penyimpanan sesi aman tidak tersedia.');
  }
}

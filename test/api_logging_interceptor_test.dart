import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_logging_interceptor.dart';

void main() {
  test('logs successful responses while redacting sensitive values', () async {
    final lines = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);

    final client = Dio(BaseOptions(baseUrl: 'https://gawen.test'));
    client.interceptors.add(ApiLoggingInterceptor());
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'ok',
                'data': {'name': 'Ayu'},
                'accessToken': 'private-access-token',
                'passwordHash': 'private-password-hash',
                'invitation': {'token': 'private-invitation-token'},
              },
            ),
            true,
          );
        },
      ),
    );

    await client.get<void>('/api/profile?token=private-query-token');

    final output = lines.join('\n');
    expect(output, contains('[API] REQUEST GET /api/profile'));
    expect(output, contains('[API] RESPONSE 200 GET'));
    expect(output, contains('"name":"Ayu"'));
    expect(output, contains('[REDACTED]'));
    expect(output, isNot(contains('private-access-token')));
    expect(output, isNot(contains('private-password-hash')));
    expect(output, isNot(contains('private-invitation-token')));
    expect(output, isNot(contains('private-query-token')));
  });

  test(
    'logs HTTP errors and redacts sensitive error response fields',
    () async {
      final lines = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
      addTearDown(() => debugPrint = originalDebugPrint);

      final client = Dio(BaseOptions(baseUrl: 'https://gawen.test'));
      client.interceptors.add(ApiLoggingInterceptor());
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'status': 'error',
                    'message': 'Kredensial tidak valid.',
                    'authorization': 'private-header-value',
                    'token': 'private-response-token',
                  },
                ),
              ),
              true,
            );
          },
        ),
      );

      await expectLater(
        client.get<void>('/api/profile'),
        throwsA(isA<DioException>()),
      );

      final output = lines.join('\n');
      expect(output, contains('[API] REQUEST GET'));
      expect(output, contains('[API] ERROR 401 GET'));
      expect(output, contains('Kredensial tidak valid.'));
      expect(output, isNot(contains('private-header-value')));
      expect(output, isNot(contains('private-response-token')));
    },
  );
}

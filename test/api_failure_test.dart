import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';

void main() {
  test('maps common HTTP and technical errors to user-friendly messages', () {
    DioException httpError(int statusCode, [Object? data]) => DioException(
      requestOptions: RequestOptions(path: '/api/resource'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/resource'),
        statusCode: statusCode,
        data: data,
      ),
    );

    expect(
      dioErrorMessage(httpError(401)),
      'Sesi Anda telah berakhir. Silakan masuk kembali.',
    );
    expect(
      dioErrorMessage(
        httpError(401, {'message': 'Email atau password tidak valid.'}),
      ),
      'Email atau password tidak valid.',
    );
    expect(
      dioErrorMessage(httpError(403)),
      'Anda tidak memiliki akses untuk melakukan tindakan ini.',
    );
    expect(
      dioErrorMessage(httpError(404)),
      'Data yang diminta tidak ditemukan.',
    );
    expect(
      dioErrorMessage(httpError(500)),
      'Terjadi masalah pada server. Silakan coba lagi.',
    );
    expect(
      dioErrorMessage(
        httpError(500, {'message': 'DioException: connection failed'}),
      ),
      'Terjadi masalah pada server. Silakan coba lagi.',
    );
  });

  test(
    'includes safe backend validation fields in the API failure message',
    () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/organizations/org-1'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/organizations/org-1'),
          statusCode: 400,
          data: {
            'status': 'error',
            'message': 'Data permintaan tidak valid.',
            'details': [
              {
                'path': 'provinceCode',
                'message': 'Kode wilayah tidak sesuai dengan wilayah induknya.',
              },
            ],
          },
        ),
      );

      expect(
        dioErrorMessage(error),
        'Data permintaan tidak valid. '
        'provinceCode: Kode wilayah tidak sesuai dengan wilayah induknya.',
      );
    },
  );
}

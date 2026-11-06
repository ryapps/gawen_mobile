import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';

void main() {
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

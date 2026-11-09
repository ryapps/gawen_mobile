import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../domain/entities/organization_entity.dart';
import '../domain/entities/organization_business_type.dart';
import 'models/organization_model.dart';

class OrganizationRepository {
  OrganizationRepository({Dio? client, FlutterSecureStorage? storage})
    : _client = client ?? ApiClient.dio,
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _client;
  final FlutterSecureStorage _storage;

  String _businessCodeStorageKey(String organizationId) =>
      'organization_business_join_code_$organizationId';

  Future<String?> getSavedBusinessJoinCode(String organizationId) async {
    try {
      return await _storage.read(key: _businessCodeStorageKey(organizationId));
    } on PlatformException {
      throw const ApiFailure(
        'Kode bergabung tidak dapat dimuat dari perangkat.',
      );
    }
  }

  Future<({String code, bool stored})> rotateBusinessJoinCode(
    String organizationId,
  ) => executeApiRequest(() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/employees/organizations/$organizationId/business-code/rotate',
    );
    final code = response.data?['data']?['businessCode'];
    if (code is! String || !RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
      throw const ApiFailure('Respons kode bergabung tidak valid.');
    }
    try {
      await _storage.write(
        key: _businessCodeStorageKey(organizationId),
        value: code,
      );
      return (code: code, stored: true);
    } on PlatformException {
      return (code: code, stored: false);
    }
  });

  Future<OrganizationEntity> getOrganization(String organizationId) =>
      executeApiRequest(() async {
        final response = await _client.get<Map<String, dynamic>>(
          '/api/organizations/$organizationId',
        );
        final organization = response.data?['data'];
        if (organization is! Map<String, dynamic> ||
            organization['organization'] is! Map<String, dynamic>) {
          throw const ApiFailure('Respons informasi usaha tidak valid.');
        }

        return OrganizationModel.fromJson(
          organization['organization'] as Map<String, dynamic>,
        );
      });

  Future<OrganizationEntity> updateOrganization({
    required String organizationId,
    required String name,
    required OrganizationBusinessType businessType,
    required String description,
    required String? logoUrl,
    required String? email,
    required String? phone,
    required String? website,
    required String? address,
    required String? city,
    required String? province,
    required String? postalCode,
    required String? currency,
    required String timezone,
  }) => executeApiRequest(() async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/organizations/$organizationId',
      data: {
        'name': name,
        'businessType': businessType.apiValue,
        'description': description,
        'logoUrl': logoUrl,
        'email': email,
        ...?phone == null ? null : {'phone': phone},
        'website': website,
        'address': address,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        ...?currency == null ? null : {'currency': currency},
        'timezone': timezone,
      },
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['organization'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons perubahan usaha tidak valid.');
    }

    return OrganizationModel.fromJson(
      data['organization'] as Map<String, dynamic>,
    );
  });

  Future<OrganizationEntity> completeSetup(String organizationId) =>
      executeApiRequest(() async {
        final response = await _client.post<Map<String, dynamic>>(
          '/api/organizations/$organizationId/setup/complete',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> ||
            data['organization'] is! Map<String, dynamic>) {
          throw const ApiFailure('Respons penyelesaian setup tidak valid.');
        }
        return OrganizationModel.fromJson(
          data['organization'] as Map<String, dynamic>,
        );
      });

  Future<OrganizationEntity> uploadLogo({
    required String organizationId,
    required String filePath,
  }) => executeApiRequest(() async {
    final extension = filePath.split('.').last.toLowerCase();
    final subType = switch (extension) {
      'jpg' || 'jpeg' => 'jpeg',
      'png' => 'png',
      'webp' => 'webp',
      _ => throw const ApiFailure('Pilih gambar JPEG, PNG, atau WebP.'),
    };
    final response = await _client.post<Map<String, dynamic>>(
      '/api/organizations/$organizationId/logo',
      data: FormData.fromMap({
        'logo': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType('image', subType),
        ),
      }),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['organization'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons upload logo tidak valid.');
    }
    return OrganizationModel.fromJson(
      data['organization'] as Map<String, dynamic>,
    );
  });

  Future<OrganizationEntity> saveSetupStep({
    required String organizationId,
    required int step,
    required Map<String, dynamic> fields,
  }) async {
    if (step == 0) {
      final response = await executeApiRequest(
        () =>
            _client.patch<Map<String, dynamic>>('/api/users/me', data: fields),
      );
      if (response.data?['data']?['user'] is! Map<String, dynamic>) {
        throw const ApiFailure('Respons penyimpanan profil tidak valid.');
      }
      await executeApiRequest(
        () => _client.patch<Map<String, dynamic>>(
          '/api/organizations/$organizationId',
          data: {'setupStep': 1},
        ),
      );
    } else {
      final response = await executeApiRequest(
        () => _client.patch<Map<String, dynamic>>(
          '/api/organizations/$organizationId',
          data: fields,
        ),
      );
      if (response.data?['data']?['organization'] is! Map<String, dynamic>) {
        throw const ApiFailure('Respons penyimpanan usaha tidak valid.');
      }
    }
    return getOrganization(organizationId);
  }
}

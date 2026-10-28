import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../domain/entities/organization_entity.dart';
import 'models/organization_model.dart';

class OrganizationRepository {
  OrganizationRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  final Dio _client;

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
    required String businessType,
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
        'businessType': businessType,
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

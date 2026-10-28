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
    required String timezone,
  }) => executeApiRequest(() async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/organizations/$organizationId',
      data: {'name': name, 'timezone': timezone},
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
}

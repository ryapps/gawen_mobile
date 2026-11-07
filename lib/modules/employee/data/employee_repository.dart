import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../../invitation/data/models/invitation_model.dart';
import '../../invitation/domain/entities/invitation_entity.dart';
import '../domain/entities/join_request_entity.dart';
import '../domain/entities/membership_entity.dart';
import 'models/join_request_model.dart';
import 'models/membership_model.dart';

class EmployeeRepository {
  EmployeeRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  final Dio _client;

  Future<List<MembershipEntity>> getMembers(String organizationId) =>
      executeApiRequest(() async {
        final response = await _client.get<Map<String, dynamic>>(
          '/api/employees/organizations/$organizationId/members',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> || data['members'] is! List) {
          throw const ApiFailure('Respons daftar karyawan tidak valid.');
        }
        final members = data['members'] as List;
        if (members.any((member) => member is! Map<String, dynamic>)) {
          throw const ApiFailure('Data karyawan tidak valid.');
        }
        return members
            .cast<Map<String, dynamic>>()
            .map(MembershipModel.fromJson)
            .toList(growable: false);
      });

  Future<MembershipEntity> getMember(
    String organizationId,
    String membershipId,
  ) => executeApiRequest(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/employees/organizations/$organizationId/members/$membershipId',
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['member'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons detail karyawan tidak valid.');
    }
    return MembershipModel.fromJson(data['member'] as Map<String, dynamic>);
  });

  Future<List<JoinRequestEntity>> getPendingRequests(String organizationId) =>
      executeApiRequest(() async {
        final response = await _client.get<Map<String, dynamic>>(
          '/api/employees/organizations/$organizationId/join-requests',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> || data['requests'] is! List) {
          throw const ApiFailure('Respons permintaan karyawan tidak valid.');
        }
        final requests = data['requests'] as List;
        if (requests.any((request) => request is! Map<String, dynamic>)) {
          throw const ApiFailure('Data permintaan karyawan tidak valid.');
        }
        return requests
            .cast<Map<String, dynamic>>()
            .map(JoinRequestModel.fromJson)
            .toList(growable: false);
      });

  Future<void> decideRequest({
    required String organizationId,
    required String requestId,
    required bool approve,
  }) => executeApiRequest(() async {
    await _client.post<Map<String, dynamic>>(
      '/api/employees/organizations/$organizationId/join-requests/$requestId/${approve ? 'approve' : 'reject'}',
    );
  });

  Future<CreatedInvitation> createInvitation({
    required String organizationId,
    required String email,
  }) => executeApiRequest(() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/employees/organizations/$organizationId/invitations',
      data: {'email': email.trim()},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['invitation'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons undangan tidak valid.');
    }
    final model = CreatedInvitationModel.fromJson(
      data['invitation'] as Map<String, dynamic>,
    );
    return CreatedInvitation(invitation: model.invitation, token: model.token);
  });

  Future<void> revokeInvitation({
    required String organizationId,
    required String invitationId,
  }) => executeApiRequest(() async {
    await _client.post<Map<String, dynamic>>(
      '/api/employees/organizations/$organizationId/invitations/$invitationId/revoke',
    );
  });
}

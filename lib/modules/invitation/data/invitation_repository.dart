import 'package:dio/dio.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/network/api_client.dart';
import '../../employees/data/models/join_request_model.dart';
import '../../employees/domain/entities/join_request_entity.dart';

class InvitationRepository {
  InvitationRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  final Dio _client;

  Future<String> requestMembership(String businessCode) =>
      executeApiRequest(() async {
        final response = await _client.post<Map<String, dynamic>>(
          '/api/employees/join-requests',
          data: {'businessCode': businessCode.trim().toUpperCase()},
        );
        final message = response.data?['message'];
        if (response.statusCode != 202 || message is! String) {
          throw const ApiFailure('Respons permintaan bergabung tidak valid.');
        }
        return message;
      });

  Future<List<JoinRequestEntity>> getOwnRequests() => executeApiRequest(
    () async {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/employees/join-requests/me',
      );
      final requests = response.data?['data'];
      if (requests is! Map<String, dynamic> || requests['requests'] is! List) {
        throw const ApiFailure('Respons status permintaan tidak valid.');
      }
      final entries = requests['requests'] as List<dynamic>;
      if (entries.any((entry) => entry is! Map<String, dynamic>)) {
        throw const ApiFailure('Data status permintaan tidak valid.');
      }
      return entries
          .cast<Map<String, dynamic>>()
          .map(JoinRequestModel.fromJson)
          .toList(growable: false);
    },
  );

  Future<void> acceptInvitation(String token) => executeApiRequest(() async {
    await _client.post<Map<String, dynamic>>(
      '/api/employees/invitations/accept',
      data: {'token': token.trim()},
    );
  });
}

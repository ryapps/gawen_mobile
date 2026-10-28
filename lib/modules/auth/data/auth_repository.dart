import 'package:dio/dio.dart';

import '../../employees/data/models/join_request_model.dart';
import '../../employees/data/models/membership_model.dart';
import '../../employees/domain/entities/join_request_entity.dart';
import '../../employees/domain/entities/membership_entity.dart';
import '../domain/entities/membership_access.dart';
import '../../../core/network/api_failure.dart';
import '../../../core/network/api_client.dart';
import 'models/user_model.dart';
import '../domain/entities/user_entity.dart';

class RestoredSession {
  const RestoredSession({
    required this.user,
    required this.memberships,
    required this.access,
    this.pendingRequest,
  });

  final UserEntity user;
  final List<MembershipEntity> memberships;
  final MembershipAccess access;
  final JoinRequestEntity? pendingRequest;
}

class AuthRepository {
  AuthRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  final Dio _client;

  Future<void> login({required String email, required String password}) =>
      executeApiRequest(() async {
        final response = await _client.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: {'email': email.trim(), 'password': password},
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> ||
            data['accessToken'] is! String ||
            data['tokenType'] != 'Bearer') {
          throw const ApiFailure('Respons login tidak valid dari server.');
        }
        await ApiClient.saveToken(data['accessToken'] as String);
      });

  Future<UserEntity> updateProfile({
    required String name,
    required String phone,
    required String? photoProfile,
  }) => executeApiRequest(() async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/me',
      data: {'name': name.trim(), 'phone': phone, 'photoProfile': photoProfile},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons perubahan profil tidak valid.');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  });

  Future<void> registerOwner({
    required String name,
    required String organizationName,
    required String email,
    required String password,
  }) => _register('/api/auth/register', {
    'name': name.trim(),
    'organizationName': organizationName.trim(),
    'email': email.trim(),
    'password': password,
  });

  Future<void> registerEmployee({
    required String name,
    required String email,
    required String password,
  }) => _register('/api/auth/register/employee', {
    'name': name.trim(),
    'email': email.trim(),
    'password': password,
  });

  Future<void> _register(String path, Map<String, Object> payload) =>
      executeApiRequest(() async {
        final response = await _client.post<Map<String, dynamic>>(
          path,
          data: payload,
        );
        if (response.statusCode != 202) {
          throw const ApiFailure('Registrasi belum dikonfirmasi oleh server.');
        }
      });

  Future<RestoredSession?> restoreSession() async {
    final token = await executeApiRequest(ApiClient.readToken);
    if (token == null || token.isEmpty) return null;
    return executeApiRequest(() async {
      try {
        final response = await _client.get<Map<String, dynamic>>(
          '/api/users/me',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> ||
            data['user'] is! Map<String, dynamic>) {
          throw const ApiFailure('Respons profil tidak valid dari server.');
        }
        final rawUser = data['user'] as Map<String, dynamic>;
        final memberships = rawUser['memberships'];
        if (memberships is! List ||
            memberships.any((item) => item is! Map<String, dynamic>)) {
          throw const ApiFailure('Data keanggotaan tidak valid dari server.');
        }
        final user = UserModel.fromJson(rawUser);
        final parsedMemberships = memberships
            .cast<Map<String, dynamic>>()
            .map(MembershipModel.fromJson)
            .toList(growable: false);
        if (memberships.isNotEmpty) {
          for (final membership in parsedMemberships) {
            if (membership.organization == null) {
              throw const ApiFailure(
                'Informasi keanggotaan tidak dapat diverifikasi.',
              );
            }
          }
          return RestoredSession(
            user: user,
            memberships: parsedMemberships,
            access: MembershipAccess.active,
          );
        }

        final requestResponse = await _client.get<Map<String, dynamic>>(
          '/api/employees/join-requests/me',
        );
        final requestData = requestResponse.data?['data'];
        if (requestData is! Map<String, dynamic> ||
            requestData['requests'] is! List) {
          throw const ApiFailure(
            'Respons status permintaan tidak valid dari server.',
          );
        }
        final requests = requestData['requests'] as List<dynamic>;
        if (requests.any((item) => item is! Map<String, dynamic>)) {
          throw const ApiFailure('Data permintaan tidak valid dari server.');
        }
        JoinRequestEntity? pendingRequest;
        for (final item in requests.cast<Map<String, dynamic>>()) {
          final request = JoinRequestModel.fromJson(item);
          if (request.status == JoinRequestStatus.pending) {
            pendingRequest = request;
            break;
          }
        }
        return RestoredSession(
          user: user,
          memberships: parsedMemberships,
          access: pendingRequest == null
              ? MembershipAccess.none
              : MembershipAccess.pending,
          pendingRequest: pendingRequest,
        );
      } on DioException catch (error) {
        if (error.response?.statusCode == 401) {
          await ApiClient.clearToken();
          throw const SessionExpiredFailure();
        }
        rethrow;
      }
    });
  }

  Future<void> logout() => executeApiRequest(() async {
    try {
      await _client.post<void>('/api/auth/logout');
    } finally {
      await ApiClient.clearToken();
    }
  });
}

import 'package:dio/dio.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/network/api_client.dart';

enum MembershipAccess { none, pending, active }

class RestoredSession {
  const RestoredSession({
    required this.user,
    required this.access,
    this.pendingRequest,
  });

  final Map<String, dynamic> user;
  final MembershipAccess access;
  final Map<String, dynamic>? pendingRequest;
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
          '/api/auth/me',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> ||
            data['user'] is! Map<String, dynamic>) {
          throw const ApiFailure('Respons profil tidak valid dari server.');
        }
        final user = data['user'] as Map<String, dynamic>;
        final memberships = user['memberships'];
        if (memberships is! List ||
            memberships.any((item) => item is! Map<String, dynamic>)) {
          throw const ApiFailure('Data keanggotaan tidak valid dari server.');
        }
        if (memberships.isNotEmpty) {
          for (final membership in memberships.cast<Map<String, dynamic>>()) {
            final role = membership['role'];
            final organization = membership['organization'];
            if ((role != 'OWNER' && role != 'EMPLOYEE') ||
                organization is! Map<String, dynamic> ||
                organization['id'] is! String ||
                organization['name'] is! String) {
              throw const ApiFailure(
                'Informasi keanggotaan tidak dapat diverifikasi.',
              );
            }
          }
          return RestoredSession(user: user, access: MembershipAccess.active);
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
        Map<String, dynamic>? pendingRequest;
        for (final item in requests.cast<Map<String, dynamic>>()) {
          if (item['status'] == 'PENDING') {
            pendingRequest = item;
            break;
          }
        }
        return RestoredSession(
          user: user,
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

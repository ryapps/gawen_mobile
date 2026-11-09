import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/network/api_failure.dart';
import 'package:frontend/modules/employee/data/employee_repository.dart';
import 'package:frontend/modules/employee/domain/entities/employee_entity.dart';
import 'package:frontend/modules/invitation/data/invitation_repository.dart';
import 'package:frontend/modules/organization/data/organization_repository.dart';
import 'package:frontend/modules/regions/data/region_repository.dart';

void main() {
  test(
    'managed employee repository sends filters and parses pagination',
    () async {
      RequestOptions? request;
      final repository = EmployeeRepository(
        client: _client((options) {
          request = options;
          return {
            'status': 'ok',
            'data': {
              'employees': [
                {
                  'id': 'employee-1',
                  'name': 'Ayu',
                  'photoProfile': null,
                  'email': 'ayu@example.com',
                  'phone': '+628123456789',
                  'position': 'Kasir',
                  'status': 'ACTIVE',
                  'joinedAt': '2026-10-01T10:00:00.000Z',
                },
              ],
              'pagination': {
                'page': 2,
                'limit': 10,
                'total': 11,
                'totalPages': 2,
              },
            },
          };
        }),
      );

      final result = await repository.getManagedEmployees(
        page: 2,
        limit: 10,
        search: 'Ayu',
        status: EmployeeEmploymentStatus.active,
      );

      expect(request?.path, '/api/employees');
      expect(request?.queryParameters, {
        'page': 2,
        'limit': 10,
        'search': 'Ayu',
        'status': 'ACTIVE',
      });
      expect(result.employees.single.name, 'Ayu');
      expect(result.employees.single.position, 'Kasir');
      expect(
        result.employees.single.joinedAt,
        DateTime.parse('2026-10-01T10:00:00.000Z'),
      );
      expect(result.pagination.hasNextPage, isFalse);
    },
  );

  test(
    'managed employee repository maps detail and update responses',
    () async {
      final paths = <String>[];
      final repository = EmployeeRepository(
        client: _client((options) {
          paths.add(options.path);
          final statusUpdate = options.path.endsWith('/status');
          return {
            'status': 'ok',
            'data': {
              'employee': {
                'id': 'employee-1',
                'name': 'Ayu',
                'position': statusUpdate ? 'Kasir' : 'Supervisor',
                'status': statusUpdate ? 'INACTIVE' : 'ACTIVE',
                'joinedAt': '2026-10-01T10:00:00.000Z',
              },
            },
          };
        }),
      );

      final detail = await repository.getManagedEmployee('employee-1');
      final updatedPosition = await repository.updateManagedEmployee(
        employeeId: 'employee-1',
        position: 'Supervisor',
      );
      final updatedStatus = await repository.updateManagedEmployeeStatus(
        employeeId: 'employee-1',
        status: EmployeeEmploymentStatus.inactive,
      );

      expect(paths, [
        '/api/employees/employee-1',
        '/api/employees/employee-1',
        '/api/employees/employee-1/status',
      ]);
      expect(detail.name, 'Ayu');
      expect(updatedPosition.position, 'Supervisor');
      expect(updatedStatus.status, EmployeeEmploymentStatus.inactive);
    },
  );

  test(
    'region repository loads and caches hierarchical API responses',
    () async {
      final paths = <String>[];
      final urls = <Uri>[];
      final client = Dio(BaseOptions(baseUrl: RegionRepository.apiBaseUrl));
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            urls.add(options.uri);
            final region = switch (options.path) {
              '/provinces.json' => {'id': '31', 'name': 'DKI Jakarta'},
              '/regencies/31.json' => {
                'id': '31.74',
                'name': 'Kota Administrasi Jakarta Selatan',
              },
              '/districts/31.74.json' => {
                'id': '31.74.07',
                'name': 'Kebayoran Baru',
              },
              '/villages/31.74.07.json' => {
                'id': '31.74.07.1002',
                'name': 'Gunung',
              },
              _ => throw StateError('Unexpected region path ${options.path}'),
            };
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [region],
                },
              ),
            );
          },
        ),
      );
      final repository = RegionRepository(client: client);

      final provinces = await repository.getProvinces();
      await repository.getProvinces();
      final regencies = await repository.getRegencies('31');
      final districts = await repository.getDistricts('31.74');
      final villages = await repository.getVillages('31.74.07');

      expect(paths, [
        '/provinces.json',
        '/regencies/31.json',
        '/districts/31.74.json',
        '/villages/31.74.07.json',
      ]);
      expect(
        urls.first,
        Uri.parse(
          'https://www.emsifa.com/api-wilayah-indonesia/v2/provinces.json',
        ),
      );
      expect(provinces.single.name, 'DKI Jakarta');
      expect(regencies.single.id, '31.74');
      expect(districts.single.name, 'Kebayoran Baru');
      expect(villages.single.id, '31.74.07.1002');
    },
  );

  test(
    'region repository reports network failures with useful detail',
    () async {
      final client = Dio(
        BaseOptions(baseUrl: 'https://www.emsifa.com/api-wilayah-indonesia/v2'),
      );
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      await expectLater(
        RegionRepository(client: client).getProvinces(),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.message,
            'message',
            contains('Tidak dapat terhubung'),
          ),
        ),
      );
    },
  );

  test('organization repository parses the existing detail response', () async {
    final paths = <String>[];
    final repository = OrganizationRepository(
      client: _client((options) {
        paths.add(options.path);
        return {
          'status': 'ok',
          'data': {
            'organization': {
              'id': 'organization-1',
              'name': 'Warung Ayu',
              'timezone': 'Asia/Jakarta',
              'memberCount': 4,
              'createdAt': '2026-10-01T10:00:00.000Z',
              'updatedAt': '2026-10-02T10:00:00.000Z',
            },
          },
        };
      }),
    );

    final organization = await repository.getOrganization('organization-1');

    expect(paths, ['/api/organizations/organization-1']);
    expect(organization.name, 'Warung Ayu');
    expect(organization.memberCount, 4);
  });

  test(
    'organization repository rotates and securely caches join codes',
    () async {
      RequestOptions? request;
      final storage = _MemorySecureStorage();
      final repository = OrganizationRepository(
        client: _client((options) {
          request = options;
          return {
            'status': 'ok',
            'data': {'businessCode': 'GAWEN123'},
          };
        }),
        storage: storage,
      );

      final result = await repository.rotateBusinessJoinCode('organization-1');
      final cachedCode = await repository.getSavedBusinessJoinCode(
        'organization-1',
      );

      expect(
        request?.path,
        '/api/employees/organizations/organization-1/business-code/rotate',
      );
      expect(result.code, 'GAWEN123');
      expect(result.stored, isTrue);
      expect(cachedCode, 'GAWEN123');
    },
  );

  test('organization repository uploads logo as multipart image', () async {
    final directory = await Directory.systemTemp.createTemp('gawen-logo-test');
    final image = File('${directory.path}\\logo.jpg');
    await image.writeAsBytes([1, 2, 3]);
    addTearDown(() => directory.delete(recursive: true));

    RequestOptions? request;
    final repository = OrganizationRepository(
      client: _client((options) {
        request = options;
        return {
          'status': 'ok',
          'data': {
            'organization': {
              'id': 'organization-1',
              'name': 'Warung Ayu',
              'timezone': 'Asia/Jakarta',
              'logoUrl': 'https://cdn.gawen.test/organization-logos/logo.jpg',
            },
          },
        };
      }),
    );

    final organization = await repository.uploadLogo(
      organizationId: 'organization-1',
      filePath: image.path,
    );

    expect(request?.path, '/api/organizations/organization-1/logo');
    expect(request?.data, isA<FormData>());
    expect((request!.data as FormData).files.single.key, 'logo');
    expect(organization.logoUrl, contains('/organization-logos/'));
  });

  test(
    'invitation repository manages owner requests and email invitations',
    () async {
      final repository = InvitationRepository(
        client: _client((options) {
          if (options.path.endsWith('/join-requests')) {
            return {
              'status': 'ok',
              'data': {
                'requests': [
                  {
                    'id': 'request-1',
                    'status': 'PENDING',
                    'createdAt': '2026-10-01T10:00:00.000Z',
                    'user': {
                      'id': 'user-2',
                      'name': 'Budi',
                      'email': 'budi@example.com',
                    },
                  },
                ],
              },
            };
          }
          if (options.path.endsWith('/invitations')) {
            expect(options.method, 'POST');
            expect(options.data, {'email': 'ayu@example.com'});
            return {
              'status': 'ok',
              'data': {
                'invitation': {
                  'id': 'invitation-1',
                  'email': 'ayu@example.com',
                  'expiresAt': '2026-10-08T10:00:00.000Z',
                  'createdAt': '2026-10-01T10:00:00.000Z',
                  'token': 'one-time-token',
                },
              },
            };
          }
          return {'status': 'ok', 'data': {}};
        }),
      );

      final pending = await repository.getOwnerRequests('organization-1');
      await repository.decideOwnerRequest(
        organizationId: 'organization-1',
        requestId: 'request-1',
        approve: true,
      );
      final invitation = await repository.createEmailInvitation(
        organizationId: 'organization-1',
        email: 'ayu@example.com',
      );
      await repository.revokeEmailInvitation(
        organizationId: 'organization-1',
        invitationId: invitation.invitation.id,
      );

      expect(pending.single.user?.name, 'Budi');
      expect(invitation.invitation.id, 'invitation-1');
      expect(invitation.token, 'one-time-token');
    },
  );

  test(
    'invitation repository parses own requests from backend payload',
    () async {
      final repository = InvitationRepository(
        client: _client((options) {
          expect(options.path, '/api/employees/join-requests/me');
          return {
            'status': 'ok',
            'data': {
              'requests': [
                {
                  'id': 'request-1',
                  'status': 'REJECTED',
                  'createdAt': '2026-10-01T10:00:00.000Z',
                  'updatedAt': '2026-10-02T10:00:00.000Z',
                  'decidedAt': '2026-10-02T10:00:00.000Z',
                  'organization': {
                    'id': 'organization-1',
                    'name': 'Warung Ayu',
                    'timezone': 'Asia/Jakarta',
                  },
                },
              ],
            },
          };
        }),
      );

      final requests = await repository.getOwnRequests();

      expect(requests.single.status?.name, 'rejected');
      expect(requests.single.organization?.name, 'Warung Ayu');
    },
  );
}

Dio _client(Map<String, dynamic> Function(RequestOptions) responseFor) {
  final client = Dio(BaseOptions(baseUrl: 'https://gawen.test'));
  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: responseFor(options),
          ),
        );
      },
    ),
  );
  return client;
}

class _MemorySecureStorage extends FlutterSecureStorage {
  final _values = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}

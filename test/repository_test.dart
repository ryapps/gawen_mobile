import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';
import 'package:frontend/modules/employee/data/employee_repository.dart';
import 'package:frontend/modules/employee/domain/entities/membership_entity.dart';
import 'package:frontend/modules/invitation/data/invitation_repository.dart';
import 'package:frontend/modules/organization/data/organization_repository.dart';
import 'package:frontend/modules/regions/data/region_repository.dart';

void main() {
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
    'employee repository maps membership and one-time invite payload',
    () async {
      final repository = EmployeeRepository(
        client: _client((options) {
          if (options.path.endsWith('/members')) {
            return {
              'status': 'ok',
              'data': {
                'members': [
                  {
                    'id': 'membership-1',
                    'role': 'EMPLOYEE',
                    'createdAt': '2026-10-01T10:00:00.000Z',
                    'user': {
                      'id': 'user-1',
                      'name': 'Ayu',
                      'email': 'ayu@example.com',
                      'phone': null,
                    },
                  },
                ],
              },
            };
          }
          if (options.path.endsWith('/join-requests')) {
            return {
              'status': 'ok',
              'data': {
                'requests': [
                  {
                    'id': 'request-1',
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
        }),
      );

      final members = await repository.getMembers('organization-1');
      final pendingRequests = await repository.getPendingRequests(
        'organization-1',
      );
      final invitation = await repository.createInvitation(
        organizationId: 'organization-1',
        email: 'ayu@example.com',
      );

      expect(members.single.role, MembershipRole.employee);
      expect(members.single.user?.phone, isNull);
      expect(pendingRequests.single.status, isNull);
      expect(pendingRequests.single.user?.name, 'Budi');
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

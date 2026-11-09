import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/auth/data/models/user_model.dart';
import 'package:frontend/modules/employee/data/models/membership_model.dart';
import 'package:frontend/modules/employee/domain/entities/membership_entity.dart';
import 'package:frontend/modules/invitation/data/models/join_request_model.dart';
import 'package:frontend/modules/invitation/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/invitation/data/models/invitation_model.dart';
import 'package:frontend/modules/organization/data/models/organization_model.dart';
import 'package:frontend/modules/organization/domain/entities/organization_business_type.dart';
import 'package:frontend/modules/regions/data/models/administrative_region_model.dart';

void main() {
  test('administrative region models accept API string and numeric IDs', () {
    expect(
      AdministrativeRegionModel.fromJson({
        'id': '31',
        'name': 'DKI Jakarta',
      }).id,
      '31',
    );
    expect(
      AdministrativeRegionModel.fromJson({'id': 3171, 'name': 'Jakarta'}).id,
      '3171',
    );
    expect(
      () => AdministrativeRegionModel.fromJson({'id': null, 'name': 'Invalid'}),
      throwsFormatException,
    );
  });

  test('organization business types map API values and Indonesian labels', () {
    expect(
      OrganizationBusinessType.values.map((type) => type.apiValue).toList(),
      [
        'FOOD_AND_BEVERAGE',
        'RETAIL',
        'SERVICES',
        'BEAUTY_AND_WELLNESS',
        'AUTOMOTIVE',
        'MANUFACTURING',
        'HOSPITALITY',
        'OTHER',
      ],
    );
    expect(OrganizationBusinessType.values.map((type) => type.label).toList(), [
      'Makanan & Minuman',
      'Retail / Perdagangan',
      'Jasa',
      'Kecantikan & Kebugaran',
      'Otomotif',
      'Manufaktur',
      'Perhotelan & Akomodasi',
      'Lainnya',
    ]);
    expect(
      OrganizationBusinessType.fromApiValue('FOOD_AND_BEVERAGE'),
      OrganizationBusinessType.foodAndBeverage,
    );
    expect(
      () => OrganizationBusinessType.fromApiValue('CAFE'),
      throwsFormatException,
    );
  });

  test('user and membership models parse and serialize profile data', () {
    final user = UserModel.fromJson({
      'id': 'user-1',
      'name': 'Ayu',
      'email': 'ayu@example.com',
      'phone': null,
    });
    final membership = MembershipModel.fromJson({
      'id': 'membership-1',
      'role': 'OWNER',
      'organization': {
        'id': 'organization-1',
        'name': 'Warung Ayu',
        'timezone': 'Asia/Jakarta',
        'businessType': 'FOOD_AND_BEVERAGE',
        'provinceCode': '31',
        'provinceName': 'DKI Jakarta',
        'regencyCode': '31.74',
        'regencyName': 'Kota Administrasi Jakarta Selatan',
        'districtCode': '31.74.07',
        'districtName': 'Kebayoran Baru',
        'villageCode': '31.74.07.1002',
        'villageName': 'Gunung',
        'setupCompletedAt': '2026-10-28T14:00:00.000Z',
      },
    });

    expect(user.phone, isNull);
    expect(membership.role, MembershipRole.owner);
    expect(membership.organization?.name, 'Warung Ayu');
    expect(membership.organization?.villageCode, '31.74.07.1002');
    expect(
      membership.organization?.businessType,
      OrganizationBusinessType.foodAndBeverage,
    );
    expect(membership.toJson()['role'], 'OWNER');
    expect(membership.toJson()['organization']['timezone'], 'Asia/Jakarta');
    expect(membership.toJson()['organization']['provinceCode'], '31');
    expect(
      membership.toJson()['organization']['setupCompletedAt'],
      '2026-10-28T14:00:00.000Z',
    );
    final serialized = user.toJson();
    expect(serialized['email'], 'ayu@example.com');
    expect(serialized.containsKey('password'), isFalse);
    expect(serialized.containsKey('passwordHash'), isFalse);
  });

  test('organization model preserves nullable count and API dates', () {
    final model = OrganizationModel.fromJson({
      'id': 'organization-1',
      'name': 'Warung Ayu',
      'timezone': 'Asia/Jakarta',
      'businessType': 'FOOD_AND_BEVERAGE',
      'provinceCode': '31',
      'provinceName': 'DKI Jakarta',
      'regencyCode': '31.74',
      'regencyName': 'Kota Administrasi Jakarta Selatan',
      'districtCode': '31.74.07',
      'districtName': 'Kebayoran Baru',
      'villageCode': '31.74.07.1002',
      'villageName': 'Gunung',
      'setupCompletedAt': '2026-10-28T14:00:00.000Z',
      'memberCount': 3,
      'createdAt': '2026-10-01T10:00:00.000Z',
      'updatedAt': '2026-10-02T10:00:00.000Z',
    });

    expect(model.memberCount, 3);
    expect(model.districtName, 'Kebayoran Baru');
    expect(model.isSetupComplete, isTrue);
    expect(model.createdAt, DateTime.utc(2026, 10, 1, 10));
    expect(model.toJson()['memberCount'], 3);
    expect(model.businessType, OrganizationBusinessType.foodAndBeverage);
    expect(model.toJson()['businessType'], 'FOOD_AND_BEVERAGE');
    expect(
      OrganizationModel.fromJson({
        'id': 'organization-2',
        'name': 'Toko',
        'timezone': 'Asia/Jakarta',
      }).memberCount,
      isNull,
    );
  });

  test('organization model rejects malformed administrative hierarchies', () {
    expect(
      () => OrganizationModel.fromJson({
        'id': 'organization-1',
        'name': 'Warung Ayu',
        'timezone': 'Asia/Jakarta',
        'provinceCode': '31',
        'provinceName': 'DKI Jakarta',
        'regencyCode': '32.73',
        'regencyName': 'Kota Bandung',
      }),
      throwsFormatException,
    );
    expect(
      () => OrganizationModel.fromJson({
        'id': 'organization-1',
        'name': 'Warung Ayu',
        'timezone': 'Asia/Jakarta',
        'provinceCode': '31',
      }),
      throwsFormatException,
    );
  });

  test('join request model converts backend status and timestamps', () {
    final request = JoinRequestModel.fromJson({
      'id': 'request-1',
      'status': 'PENDING',
      'createdAt': '2026-10-01T10:00:00.000Z',
      'updatedAt': '2026-10-01T10:00:00.000Z',
      'decidedAt': null,
      'organization': {
        'id': 'organization-1',
        'name': 'Warung Ayu',
        'timezone': 'Asia/Jakarta',
      },
    });

    expect(request.status, JoinRequestStatus.pending);
    expect(request.organization?.id, 'organization-1');
    expect(request.decidedAt, isNull);
    expect(request.toJson()['status'], 'PENDING');
  });

  test('invitation token is isolated from the general invitation entity', () {
    const token = 'one-time-token';
    final created = CreatedInvitationModel.fromJson({
      'id': 'invitation-1',
      'email': 'employee@example.com',
      'expiresAt': '2026-10-08T10:00:00.000Z',
      'createdAt': '2026-10-01T10:00:00.000Z',
      'token': token,
    });

    expect(created.token, token);
    expect(created.invitation.toJson().containsKey('token'), isFalse);
  });

  test('malformed backend model data is rejected explicitly', () {
    expect(
      () => OrganizationModel.fromJson({
        'id': 'organization-1',
        'name': 'Warung',
      }),
      throwsFormatException,
    );
    expect(
      () => OrganizationModel.fromJson({
        'id': 'organization-1',
        'name': 'Warung',
        'timezone': 'Asia/Jakarta',
        'businessType': 'CAFE',
      }),
      throwsFormatException,
    );
    expect(
      () => JoinRequestModel.fromJson({'id': 'request-1', 'status': 'UNKNOWN'}),
      throwsFormatException,
    );
  });
}

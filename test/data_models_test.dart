import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/auth/data/models/user_model.dart';
import 'package:frontend/modules/employees/data/models/join_request_model.dart';
import 'package:frontend/modules/employees/data/models/membership_model.dart';
import 'package:frontend/modules/employees/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/employees/domain/entities/membership_entity.dart';
import 'package:frontend/modules/invitation/data/models/invitation_model.dart';
import 'package:frontend/modules/organization/data/models/organization_model.dart';

void main() {
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
      },
    });

    expect(user.phone, isNull);
    expect(membership.role, MembershipRole.owner);
    expect(membership.organization?.name, 'Warung Ayu');
    expect(membership.toJson()['role'], 'OWNER');
    expect(membership.toJson()['organization']['timezone'], 'Asia/Jakarta');
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
      'memberCount': 3,
      'createdAt': '2026-10-01T10:00:00.000Z',
      'updatedAt': '2026-10-02T10:00:00.000Z',
    });

    expect(model.memberCount, 3);
    expect(model.createdAt, DateTime.utc(2026, 10, 1, 10));
    expect(model.toJson()['memberCount'], 3);
    expect(
      OrganizationModel.fromJson({
        'id': 'organization-2',
        'name': 'Toko',
        'timezone': 'Asia/Jakarta',
      }).memberCount,
      isNull,
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
      () => JoinRequestModel.fromJson({'id': 'request-1', 'status': 'UNKNOWN'}),
      throwsFormatException,
    );
  });
}

import '../../../auth/domain/entities/user_entity.dart';
import '../../../organization/domain/entities/organization_entity.dart';

enum MembershipRole { owner, employee }

class MembershipEntity {
  const MembershipEntity({
    required this.id,
    required this.role,
    this.userId,
    this.organizationId,
    this.user,
    this.organization,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String? organizationId;
  final MembershipRole role;
  final UserEntity? user;
  final OrganizationEntity? organization;
  final DateTime? createdAt;
}

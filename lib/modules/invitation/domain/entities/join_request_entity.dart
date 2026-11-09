import '../../../auth/domain/entities/user_entity.dart';
import '../../../organization/domain/entities/organization_entity.dart';

enum JoinRequestStatus { pending, approved, rejected }

class JoinRequestEntity {
  const JoinRequestEntity({
    required this.id,
    this.status,
    this.user,
    this.organization,
    this.createdAt,
    this.updatedAt,
    this.decidedAt,
  });

  final String id;
  final JoinRequestStatus? status;
  final UserEntity? user;
  final OrganizationEntity? organization;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? decidedAt;
}

import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../organization/data/models/organization_model.dart';
import '../../../organization/domain/entities/organization_entity.dart';
import '../../domain/entities/membership_entity.dart';

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    required super.id,
    required super.role,
    super.userId,
    super.organizationId,
    super.user,
    super.organization,
    super.createdAt,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final rawRole = json['role'];
    final rawUser = json['user'];
    final rawOrganization = json['organization'];
    final rawCreatedAt = json['createdAt'];
    if (id is! String ||
        (rawRole != 'OWNER' && rawRole != 'EMPLOYEE') ||
        (rawUser != null && rawUser is! Map<String, dynamic>) ||
        (rawOrganization != null && rawOrganization is! Map<String, dynamic>) ||
        (rawCreatedAt != null && rawCreatedAt is! String)) {
      throw const FormatException('Data keanggotaan tidak valid.');
    }
    final userModel = rawUser == null ? null : UserModel.fromJson(rawUser);
    final organizationModel = rawOrganization == null
        ? null
        : OrganizationModel.fromJson(rawOrganization);
    return MembershipModel(
      id: id,
      role: rawRole == 'OWNER' ? MembershipRole.owner : MembershipRole.employee,
      userId: userModel?.id,
      organizationId: organizationModel?.id,
      user: userModel,
      organization: organizationModel,
      createdAt: rawCreatedAt == null
          ? null
          : _parseDate(rawCreatedAt as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role == MembershipRole.owner ? 'OWNER' : 'EMPLOYEE',
    if (user != null) 'user': _userJson(user!),
    if (organization != null) 'organization': _organizationJson(organization!),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}

Map<String, dynamic> _userJson(UserEntity user) => {
  'id': user.id,
  'name': user.name,
  'email': user.email,
  'phone': user.phone,
  'photoProfile': user.photoProfile,
};

Map<String, dynamic> _organizationJson(OrganizationEntity organization) => {
  'id': organization.id,
  'name': organization.name,
  'timezone': organization.timezone,
  'businessType': organization.businessType,
  'description': organization.description,
  'logoUrl': organization.logoUrl,
  'email': organization.email,
  'phone': organization.phone,
  'website': organization.website,
  'address': organization.address,
  'city': organization.city,
  'province': organization.province,
  'postalCode': organization.postalCode,
  'currency': organization.currency,
  if (organization.setupCompletedAt != null)
    'setupCompletedAt': organization.setupCompletedAt!.toIso8601String(),
  if (organization.memberCount != null) 'memberCount': organization.memberCount,
  if (organization.createdAt != null)
    'createdAt': organization.createdAt!.toIso8601String(),
  if (organization.updatedAt != null)
    'updatedAt': organization.updatedAt!.toIso8601String(),
};

DateTime _parseDate(String value) =>
    DateTime.tryParse(value) ??
    (throw const FormatException('Tanggal keanggotaan tidak valid.'));

import '../../../auth/data/models/user_model.dart';
import '../../../organization/data/models/organization_model.dart';
import '../../domain/entities/join_request_entity.dart';

class JoinRequestModel extends JoinRequestEntity {
  const JoinRequestModel({
    required super.id,
    required super.status,
    super.user,
    super.organization,
    super.createdAt,
    super.updatedAt,
    super.decidedAt,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final rawStatus = json['status'];
    final rawUser = json['user'];
    final rawOrganization = json['organization'];
    if (id is! String ||
        (rawStatus != null &&
            rawStatus != 'PENDING' &&
            rawStatus != 'APPROVED' &&
            rawStatus != 'REJECTED') ||
        (rawUser != null && rawUser is! Map<String, dynamic>) ||
        (rawOrganization != null && rawOrganization is! Map<String, dynamic>)) {
      throw const FormatException('Data permintaan bergabung tidak valid.');
    }
    return JoinRequestModel(
      id: id,
      status: switch (rawStatus) {
        null => null,
        'PENDING' => JoinRequestStatus.pending,
        'APPROVED' => JoinRequestStatus.approved,
        'REJECTED' => JoinRequestStatus.rejected,
        _ => throw const FormatException(
          'Status permintaan bergabung tidak valid.',
        ),
      },
      user: rawUser == null
          ? null
          : UserModel.fromJson(rawUser as Map<String, dynamic>),
      organization: rawOrganization == null
          ? null
          : OrganizationModel.fromJson(rawOrganization as Map<String, dynamic>),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      decidedAt: _date(json['decidedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (status != null)
      'status': switch (status!) {
        JoinRequestStatus.pending => 'PENDING',
        JoinRequestStatus.approved => 'APPROVED',
        JoinRequestStatus.rejected => 'REJECTED',
      },
    if (user != null)
      'user': {
        'id': user!.id,
        'name': user!.name,
        'email': user!.email,
        'phone': user!.phone,
      },
    if (organization != null)
      'organization': {
        'id': organization!.id,
        'name': organization!.name,
        'timezone': organization!.timezone,
        if (organization!.memberCount != null)
          'memberCount': organization!.memberCount,
        if (organization!.createdAt != null)
          'createdAt': organization!.createdAt!.toIso8601String(),
        if (organization!.updatedAt != null)
          'updatedAt': organization!.updatedAt!.toIso8601String(),
      },
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    if (decidedAt != null) 'decidedAt': decidedAt!.toIso8601String(),
  };
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Tanggal permintaan bergabung tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException(
        'Tanggal permintaan bergabung tidak valid.',
      ));
}

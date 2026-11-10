import '../../domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.email,
    required super.expiresAt,
    required super.createdAt,
    super.organizationName,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    final organization = json['organization'];
    if (id is! String || email is! String) {
      throw const FormatException('Data undangan tidak valid.');
    }
    if (organization != null &&
        (organization is! Map<String, dynamic> ||
            organization['name'] is! String)) {
      throw const FormatException('Data organisasi undangan tidak valid.');
    }
    return InvitationModel(
      id: id,
      email: email,
      expiresAt: _date(json['expiresAt']),
      createdAt: _date(json['createdAt']),
      organizationName: organization is Map<String, dynamic>
          ? organization['name'] as String
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    if (organizationName != null) 'organizationName': organizationName,
  };
}

class CreatedInvitationModel {
  const CreatedInvitationModel({required this.invitation});

  final InvitationModel invitation;

  factory CreatedInvitationModel.fromJson(Map<String, dynamic> json) {
    return CreatedInvitationModel(invitation: InvitationModel.fromJson(json));
  }
}

DateTime _date(Object? value) {
  if (value is! String) {
    throw const FormatException('Tanggal undangan tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Tanggal undangan tidak valid.'));
}

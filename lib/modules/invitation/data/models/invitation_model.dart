import '../../domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.email,
    required super.expiresAt,
    required super.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final email = json['email'];
    if (id is! String || email is! String) {
      throw const FormatException('Data undangan tidak valid.');
    }
    return InvitationModel(
      id: id,
      email: email,
      expiresAt: _date(json['expiresAt']),
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
}

class CreatedInvitationModel {
  const CreatedInvitationModel({required this.invitation, required this.token});

  final InvitationModel invitation;
  final String token;

  factory CreatedInvitationModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Token undangan tidak valid.');
    }
    return CreatedInvitationModel(
      invitation: InvitationModel.fromJson(json),
      token: token,
    );
  }
}

DateTime _date(Object? value) {
  if (value is! String) {
    throw const FormatException('Tanggal undangan tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Tanggal undangan tidak valid.'));
}

class InvitationEntity {
  const InvitationEntity({
    required this.id,
    required this.email,
    required this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String email;
  final DateTime expiresAt;
  final DateTime createdAt;
}

class CreatedInvitation {
  const CreatedInvitation({required this.invitation, required this.token});

  final InvitationEntity invitation;
  final String token;
}

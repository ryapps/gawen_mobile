class InvitationEntity {
  const InvitationEntity({
    required this.id,
    required this.email,
    required this.expiresAt,
    required this.createdAt,
    this.organizationName,
  });

  final String id;
  final String email;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String? organizationName;
}

class CreatedInvitation {
  const CreatedInvitation({required this.invitation});

  final InvitationEntity invitation;
}

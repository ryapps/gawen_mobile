sealed class InvitationEvent {
  const InvitationEvent();
}

final class InvitationStateResetRequested extends InvitationEvent {
  const InvitationStateResetRequested();
}

final class RequestsRefreshRequested extends InvitationEvent {
  const RequestsRefreshRequested();
}

final class BusinessCodeSubmitted extends InvitationEvent {
  const BusinessCodeSubmitted(this.businessCode);

  final String businessCode;
}

final class InvitationAccepted extends InvitationEvent {
  const InvitationAccepted(this.token);

  final String token;
}

final class OwnerJoinRequestsRefreshRequested extends InvitationEvent {
  const OwnerJoinRequestsRefreshRequested(this.organizationId);

  final String organizationId;
}

final class OwnerJoinRequestDecisionRequested extends InvitationEvent {
  const OwnerJoinRequestDecisionRequested({
    required this.organizationId,
    required this.requestId,
    required this.approve,
  });

  final String organizationId;
  final String requestId;
  final bool approve;
}

final class EmailInvitationCreatedRequested extends InvitationEvent {
  const EmailInvitationCreatedRequested({
    required this.organizationId,
    required this.email,
  });

  final String organizationId;
  final String email;
}

final class EmailInvitationRevokedRequested extends InvitationEvent {
  const EmailInvitationRevokedRequested({
    required this.organizationId,
    required this.invitationId,
  });

  final String organizationId;
  final String invitationId;
}

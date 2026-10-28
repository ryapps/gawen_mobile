sealed class InvitationEvent {
  const InvitationEvent();
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

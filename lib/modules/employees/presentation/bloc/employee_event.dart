sealed class EmployeeEvent {
  const EmployeeEvent();
}

final class EmployeeDataRequested extends EmployeeEvent {
  const EmployeeDataRequested(this.organizationId);

  final String organizationId;
}

final class EmployeeDetailRequested extends EmployeeEvent {
  const EmployeeDetailRequested({
    required this.organizationId,
    required this.membershipId,
  });

  final String organizationId;
  final String membershipId;
}

final class EmployeeInvitationRequested extends EmployeeEvent {
  const EmployeeInvitationRequested({
    required this.organizationId,
    required this.email,
  });

  final String organizationId;
  final String email;
}

final class EmployeeInvitationRevocationRequested extends EmployeeEvent {
  const EmployeeInvitationRevocationRequested({
    required this.organizationId,
    required this.invitationId,
  });

  final String organizationId;
  final String invitationId;
}

final class JoinRequestDecisionRequested extends EmployeeEvent {
  const JoinRequestDecisionRequested({
    required this.organizationId,
    required this.requestId,
    required this.approve,
  });

  final String organizationId;
  final String requestId;
  final bool approve;
}

final class EmployeeStateResetRequested extends EmployeeEvent {
  const EmployeeStateResetRequested();
}

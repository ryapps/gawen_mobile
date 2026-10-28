sealed class OrganizationEvent {
  const OrganizationEvent();
}

final class OrganizationLoadRequested extends OrganizationEvent {
  const OrganizationLoadRequested(this.organizationId);

  final String organizationId;
}

final class OrganizationUpdateRequested extends OrganizationEvent {
  const OrganizationUpdateRequested({
    required this.organizationId,
    required this.name,
    required this.timezone,
  });

  final String organizationId;
  final String name;
  final String timezone;
}

final class OrganizationStateResetRequested extends OrganizationEvent {
  const OrganizationStateResetRequested();
}

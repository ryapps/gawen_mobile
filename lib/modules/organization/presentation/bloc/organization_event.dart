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
    required this.businessType,
    required this.description,
    required this.logoUrl,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.currency,
    required this.timezone,
  });

  final String organizationId;
  final String name;
  final String businessType;
  final String description;
  final String? logoUrl;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? currency;
  final String timezone;
}

final class OrganizationStateResetRequested extends OrganizationEvent {
  const OrganizationStateResetRequested();
}

final class OrganizationSetupCompletionRequested extends OrganizationEvent {
  const OrganizationSetupCompletionRequested(this.organizationId);

  final String organizationId;
}

final class OrganizationSetupStepSaveRequested extends OrganizationEvent {
  const OrganizationSetupStepSaveRequested({
    required this.organizationId,
    required this.step,
    required this.fields,
  });

  final String organizationId;
  final int step;
  final Map<String, dynamic> fields;
}

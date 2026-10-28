class OrganizationEntity {
  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.timezone,
    this.businessType,
    this.description,
    this.logoUrl,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.currency,
    this.setupCompletedAt,
    this.setupStep = 0,
    this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String timezone;
  final String? businessType;
  final String? description;
  final String? logoUrl;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? currency;
  final DateTime? setupCompletedAt;
  final int setupStep;
  final int? memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSetupComplete =>
      setupCompletedAt != null && (businessType?.trim().isNotEmpty ?? false);
}

class OrganizationEntity {
  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.timezone,
    this.memberCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String timezone;
  final int? memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

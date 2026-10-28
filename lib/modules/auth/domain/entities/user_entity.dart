class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

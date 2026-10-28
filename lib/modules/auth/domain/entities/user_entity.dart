class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoProfile,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

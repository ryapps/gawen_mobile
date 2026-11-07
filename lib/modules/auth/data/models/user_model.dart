import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.photoProfile,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final phone = json['phone'];
    final photoProfile = json['photoProfile'];
    if (id is! String ||
        name is! String ||
        email is! String ||
        (phone != null && phone is! String) ||
        (photoProfile != null && photoProfile is! String)) {
      throw const FormatException('Data profil pengguna tidak valid.');
    }
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone as String?,
      photoProfile: photoProfile as String?,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'photoProfile': photoProfile,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Tanggal profil pengguna tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Tanggal profil pengguna tidak valid.'));
}

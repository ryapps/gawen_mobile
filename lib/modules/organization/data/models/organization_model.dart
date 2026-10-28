import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.timezone,
    super.memberCount,
    super.createdAt,
    super.updatedAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final timezone = json['timezone'];
    final memberCount = json['memberCount'];
    if (id is! String || name is! String || timezone is! String) {
      throw const FormatException('Data organisasi tidak valid.');
    }
    if (memberCount != null && memberCount is! int) {
      throw const FormatException('Jumlah anggota organisasi tidak valid.');
    }
    return OrganizationModel(
      id: id,
      name: name,
      timezone: timezone,
      memberCount: memberCount as int?,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'timezone': timezone,
    if (memberCount != null) 'memberCount': memberCount,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Tanggal organisasi tidak valid.');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Tanggal organisasi tidak valid.'));
}

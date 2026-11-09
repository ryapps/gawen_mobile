import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.status,
    super.photoProfile,
    super.email,
    super.phone,
    super.position,
    super.joinedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final status = json['status'];
    final photoProfile = _nullableString(json, 'photoProfile');
    final email = _nullableString(json, 'email');
    final phone = _nullableString(json, 'phone');
    final position = _nullableString(json, 'position');
    final joinedAt = json['joinedAt'];
    if (id is! String ||
        name is! String ||
        (status != 'ACTIVE' && status != 'INACTIVE') ||
        (joinedAt != null && joinedAt is! String)) {
      throw const FormatException('Data karyawan tidak valid.');
    }

    return EmployeeModel(
      id: id,
      name: name,
      photoProfile: photoProfile,
      email: email,
      phone: phone,
      position: position,
      status: status == 'ACTIVE'
          ? EmployeeEmploymentStatus.active
          : EmployeeEmploymentStatus.inactive,
      joinedAt: joinedAt == null
          ? null
          : DateTime.tryParse(joinedAt as String) ??
                (throw const FormatException('Tanggal bergabung tidak valid.')),
    );
  }
}

class EmployeePaginationModel extends EmployeePagination {
  const EmployeePaginationModel({
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
  });

  factory EmployeePaginationModel.fromJson(Map<String, dynamic> json) {
    final page = json['page'];
    final limit = json['limit'];
    final total = json['total'];
    final totalPages = json['totalPages'];
    if (page is! int ||
        limit is! int ||
        total is! int ||
        totalPages is! int ||
        page < 1 ||
        limit < 1 ||
        total < 0 ||
        totalPages < 0) {
      throw const FormatException('Data pagination karyawan tidak valid.');
    }
    return EmployeePaginationModel(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
    );
  }
}

String? _nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value != null && value is! String) {
    throw FormatException('Data karyawan ($key) tidak valid.');
  }
  return value as String?;
}

class EmployeeEntity {
  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.status,
    this.photoProfile,
    this.email,
    this.phone,
    this.position,
    this.joinedAt,
  });

  final String id;
  final String name;
  final String? photoProfile;
  final String? email;
  final String? phone;
  final String? position;
  final EmployeeEmploymentStatus status;
  final DateTime? joinedAt;
}

enum EmployeeEmploymentStatus { active, inactive }

class EmployeePagination {
  const EmployeePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
}

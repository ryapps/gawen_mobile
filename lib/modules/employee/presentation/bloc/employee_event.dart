import '../../domain/entities/employee_entity.dart';

sealed class EmployeeEvent {
  const EmployeeEvent();
}

final class ManagedEmployeesRequested extends EmployeeEvent {
  const ManagedEmployeesRequested({this.search = '', this.status});

  final String search;
  final EmployeeEmploymentStatus? status;
}

final class ManagedEmployeesLoadMoreRequested extends EmployeeEvent {
  const ManagedEmployeesLoadMoreRequested();
}

final class ManagedEmployeeDetailRequested extends EmployeeEvent {
  const ManagedEmployeeDetailRequested(this.employeeId);

  final String employeeId;
}

final class ManagedEmployeePositionUpdateRequested extends EmployeeEvent {
  const ManagedEmployeePositionUpdateRequested({
    required this.employeeId,
    required this.position,
  });

  final String employeeId;
  final String? position;
}

final class ManagedEmployeeStatusUpdateRequested extends EmployeeEvent {
  const ManagedEmployeeStatusUpdateRequested({
    required this.employeeId,
    required this.status,
  });

  final String employeeId;
  final EmployeeEmploymentStatus status;
}

final class EmployeeStateResetRequested extends EmployeeEvent {
  const EmployeeStateResetRequested();
}

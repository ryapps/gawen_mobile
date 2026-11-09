import '../../domain/entities/employee_entity.dart';

enum EmployeeStatus { initial, loading, ready, mutating, failure }

enum EmployeeListStatus { initial, loading, loadingMore, ready, failure }

enum EmployeeDetailStatus { initial, loading, ready, failure }

class EmployeeState {
  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.managedEmployees = const [],
    this.employeePagination,
    this.selectedEmployee,
    this.detailStatus = EmployeeDetailStatus.initial,
    this.detailMessage,
    this.listStatus = EmployeeListStatus.initial,
    this.listMessage,
    this.search = '',
    this.filterStatus,
    this.message,
  });

  final EmployeeStatus status;
  final List<EmployeeEntity> managedEmployees;
  final EmployeePagination? employeePagination;
  final EmployeeEntity? selectedEmployee;
  final EmployeeDetailStatus detailStatus;
  final String? detailMessage;
  final EmployeeListStatus listStatus;
  final String? listMessage;
  final String search;
  final EmployeeEmploymentStatus? filterStatus;
  final String? message;

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<EmployeeEntity>? managedEmployees,
    EmployeePagination? employeePagination,
    EmployeeEntity? selectedEmployee,
    EmployeeDetailStatus? detailStatus,
    String? detailMessage,
    EmployeeListStatus? listStatus,
    String? listMessage,
    String? search,
    EmployeeEmploymentStatus? filterStatus,
    String? message,
    bool clearEmployeePagination = false,
    bool clearSelectedEmployee = false,
    bool clearFilterStatus = false,
    bool clearListMessage = false,
    bool clearDetailMessage = false,
  }) => EmployeeState(
    status: status ?? this.status,
    managedEmployees: managedEmployees ?? this.managedEmployees,
    employeePagination: clearEmployeePagination
        ? null
        : employeePagination ?? this.employeePagination,
    selectedEmployee: clearSelectedEmployee
        ? null
        : selectedEmployee ?? this.selectedEmployee,
    detailStatus: detailStatus ?? this.detailStatus,
    detailMessage: clearDetailMessage
        ? null
        : detailMessage ?? this.detailMessage,
    listStatus: listStatus ?? this.listStatus,
    listMessage: clearListMessage ? null : listMessage ?? this.listMessage,
    search: search ?? this.search,
    filterStatus: clearFilterStatus ? null : filterStatus ?? this.filterStatus,
    message: message,
  );
}

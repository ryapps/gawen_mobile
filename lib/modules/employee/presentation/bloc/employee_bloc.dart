import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/employee_repository.dart';
import '../../domain/entities/employee_entity.dart';
import 'employee_event.dart';
import 'employee_state.dart';

export 'employee_event.dart';
export 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc(this._repository) : super(const EmployeeState()) {
    on<EmployeeStateResetRequested>((event, emit) {
      _listRequestGeneration++;
      emit(const EmployeeState());
    });
    on<ManagedEmployeesRequested>(_loadManagedEmployees);
    on<ManagedEmployeesLoadMoreRequested>(_loadMoreManagedEmployees);
    on<ManagedEmployeeDetailRequested>(_loadManagedEmployee);
    on<ManagedEmployeePositionUpdateRequested>(_updateManagedEmployeePosition);
    on<ManagedEmployeeStatusUpdateRequested>(_updateManagedEmployeeStatus);
  }

  final EmployeeRepository _repository;
  int _listRequestGeneration = 0;
  int _detailRequestGeneration = 0;
  static const _managedEmployeesPageSize = 20;

  Future<void> _loadManagedEmployees(
    ManagedEmployeesRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    final generation = ++_listRequestGeneration;
    emit(
      state.copyWith(
        listStatus: EmployeeListStatus.loading,
        search: event.search.trim(),
        filterStatus: event.status,
        clearFilterStatus: event.status == null,
        clearListMessage: true,
        clearEmployeePagination: true,
        managedEmployees: const [],
      ),
    );
    try {
      final result = await _repository.getManagedEmployees(
        page: 1,
        limit: _managedEmployeesPageSize,
        search: event.search,
        status: event.status,
      );
      if (generation != _listRequestGeneration) return;
      emit(
        state.copyWith(
          listStatus: EmployeeListStatus.ready,
          managedEmployees: result.employees,
          employeePagination: result.pagination,
          clearListMessage: true,
        ),
      );
    } on ApiFailure catch (error) {
      if (generation != _listRequestGeneration) return;
      emit(
        state.copyWith(
          listStatus: EmployeeListStatus.failure,
          listMessage: error.message,
        ),
      );
    }
  }

  Future<void> _loadMoreManagedEmployees(
    ManagedEmployeesLoadMoreRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    final pagination = state.employeePagination;
    if (state.listStatus == EmployeeListStatus.loading ||
        state.listStatus == EmployeeListStatus.loadingMore ||
        pagination == null ||
        !pagination.hasNextPage) {
      return;
    }
    final generation = _listRequestGeneration;
    emit(
      state.copyWith(
        listStatus: EmployeeListStatus.loadingMore,
        clearListMessage: true,
      ),
    );
    try {
      final result = await _repository.getManagedEmployees(
        page: pagination.page + 1,
        limit: pagination.limit,
        search: state.search,
        status: state.filterStatus,
      );
      if (generation != _listRequestGeneration) return;
      final existingIds = state.managedEmployees
          .map((employee) => employee.id)
          .toSet();
      final employees = [
        ...state.managedEmployees,
        ...result.employees.where((employee) => existingIds.add(employee.id)),
      ];
      emit(
        state.copyWith(
          listStatus: EmployeeListStatus.ready,
          managedEmployees: employees,
          employeePagination: result.pagination,
          clearListMessage: true,
        ),
      );
    } on ApiFailure catch (error) {
      if (generation != _listRequestGeneration) return;
      emit(
        state.copyWith(
          listStatus: EmployeeListStatus.failure,
          listMessage: error.message,
        ),
      );
    }
  }

  Future<void> _loadManagedEmployee(
    ManagedEmployeeDetailRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    final generation = ++_detailRequestGeneration;
    emit(
      state.copyWith(
        detailStatus: EmployeeDetailStatus.loading,
        clearSelectedEmployee: true,
        clearDetailMessage: true,
      ),
    );
    try {
      final employee = await _repository.getManagedEmployee(event.employeeId);
      if (generation != _detailRequestGeneration) return;
      emit(
        state.copyWith(
          detailStatus: EmployeeDetailStatus.ready,
          selectedEmployee: employee,
          clearDetailMessage: true,
        ),
      );
    } on ApiFailure catch (error) {
      if (generation != _detailRequestGeneration) return;
      emit(
        state.copyWith(
          detailStatus: EmployeeDetailStatus.failure,
          detailMessage: error.message,
        ),
      );
    }
  }

  Future<void> _updateManagedEmployeePosition(
    ManagedEmployeePositionUpdateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.mutating) return;
    emit(state.copyWith(status: EmployeeStatus.mutating, message: null));
    try {
      final updated = await _repository.updateManagedEmployee(
        employeeId: event.employeeId,
        position: event.position,
      );
      _emitManagedEmployeeUpdate(
        emit,
        updated,
        'Informasi pekerjaan diperbarui.',
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  Future<void> _updateManagedEmployeeStatus(
    ManagedEmployeeStatusUpdateRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.mutating) return;
    emit(state.copyWith(status: EmployeeStatus.mutating, message: null));
    try {
      final updated = await _repository.updateManagedEmployeeStatus(
        employeeId: event.employeeId,
        status: event.status,
      );
      _emitManagedEmployeeUpdate(emit, updated, 'Status karyawan diperbarui.');
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  void _emitManagedEmployeeUpdate(
    Emitter<EmployeeState> emit,
    EmployeeEntity updated,
    String message,
  ) {
    EmployeeEntity? previous;
    for (final employee in state.managedEmployees) {
      if (employee.id == updated.id) {
        previous = employee;
        break;
      }
    }
    final remainsInFilter =
        state.filterStatus == null || state.filterStatus == updated.status;
    final managedEmployees = state.managedEmployees
        .where((employee) => employee.id != updated.id || remainsInFilter)
        .map((employee) => employee.id == updated.id ? updated : employee)
        .toList(growable: false);
    final oldMatchedFilter =
        previous != null &&
        (state.filterStatus == null || previous.status == state.filterStatus);
    final total = state.employeePagination?.total;
    final nextTotal = total == null
        ? null
        : oldMatchedFilter && !remainsInFilter
        ? total - 1
        : total;
    final pagination = state.employeePagination;
    emit(
      state.copyWith(
        status: EmployeeStatus.ready,
        selectedEmployee: updated,
        managedEmployees: managedEmployees,
        employeePagination: pagination == null || nextTotal == null
            ? null
            : EmployeePagination(
                page: pagination.page,
                limit: pagination.limit,
                total: nextTotal,
                totalPages: (nextTotal / pagination.limit).ceil(),
              ),
        message: message,
      ),
    );
  }
}

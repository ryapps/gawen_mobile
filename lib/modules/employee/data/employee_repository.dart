import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../domain/entities/employee_entity.dart';
import 'models/employee_model.dart';

class EmployeeRepository {
  EmployeeRepository({Dio? client}) : _client = client ?? ApiClient.dio;

  final Dio _client;

  Future<({List<EmployeeEntity> employees, EmployeePagination pagination})>
  getManagedEmployees({
    required int page,
    required int limit,
    String? search,
    EmployeeEmploymentStatus? status,
  }) => executeApiRequest(() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/employees',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null)
          'status': status == EmployeeEmploymentStatus.active
              ? 'ACTIVE'
              : 'INACTIVE',
      },
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic> ||
        data['employees'] is! List ||
        data['pagination'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons daftar karyawan tidak valid.');
    }
    final records = data['employees'] as List;
    if (records.any((employee) => employee is! Map<String, dynamic>)) {
      throw const ApiFailure('Data karyawan tidak valid.');
    }
    return (
      employees: records
          .cast<Map<String, dynamic>>()
          .map(EmployeeModel.fromJson)
          .toList(growable: false),
      pagination: EmployeePaginationModel.fromJson(
        data['pagination'] as Map<String, dynamic>,
      ),
    );
  });

  Future<EmployeeEntity> getManagedEmployee(String employeeId) =>
      executeApiRequest(() async {
        final response = await _client.get<Map<String, dynamic>>(
          '/api/employees/$employeeId',
        );
        final data = response.data?['data'];
        if (data is! Map<String, dynamic> ||
            data['employee'] is! Map<String, dynamic>) {
          throw const ApiFailure('Respons detail karyawan tidak valid.');
        }
        return EmployeeModel.fromJson(data['employee'] as Map<String, dynamic>);
      });

  Future<EmployeeEntity> updateManagedEmployee({
    required String employeeId,
    required String? position,
  }) => executeApiRequest(() async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/employees/$employeeId',
      data: {'position': position?.trim()},
    );
    return _managedEmployeeFromResponse(response.data);
  });

  Future<EmployeeEntity> updateManagedEmployeeStatus({
    required String employeeId,
    required EmployeeEmploymentStatus status,
  }) => executeApiRequest(() async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/employees/$employeeId/status',
      data: {
        'status': status == EmployeeEmploymentStatus.active
            ? 'ACTIVE'
            : 'INACTIVE',
      },
    );
    return _managedEmployeeFromResponse(response.data);
  });

  EmployeeEntity _managedEmployeeFromResponse(Map<String, dynamic>? response) {
    final data = response?['data'];
    if (data is! Map<String, dynamic> ||
        data['employee'] is! Map<String, dynamic>) {
      throw const ApiFailure('Respons perubahan karyawan tidak valid.');
    }
    return EmployeeModel.fromJson(data['employee'] as Map<String, dynamic>);
  }
}

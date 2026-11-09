import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';
import 'package:frontend/modules/auth/data/auth_repository.dart';
import 'package:frontend/modules/auth/domain/entities/user_entity.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/employee/data/employee_repository.dart';
import 'package:frontend/modules/employee/domain/entities/employee_entity.dart';
import 'package:frontend/modules/employee/presentation/bloc/employee_bloc.dart';
import 'package:frontend/modules/invitation/data/invitation_repository.dart';
import 'package:frontend/modules/invitation/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/invitation/presentation/bloc/invitation_bloc.dart';
import 'package:frontend/modules/organization/data/organization_repository.dart';
import 'package:frontend/modules/organization/domain/entities/organization_entity.dart';
import 'package:frontend/modules/organization/presentation/bloc/organization_bloc.dart';

void main() {
  test('owner join request decisions refresh the request list', () async {
    final repository = _FakeInvitationRepository();
    final bloc = InvitationBloc(repository);
    bloc.add(const OwnerJoinRequestsRefreshRequested('organization-1'));
    await bloc.stream.firstWhere(
      (state) => state.ownerRequestsStatus == OwnerJoinRequestsStatus.ready,
    );

    bloc.add(
      const OwnerJoinRequestDecisionRequested(
        organizationId: 'organization-1',
        requestId: 'request-1',
        approve: true,
      ),
    );
    final updated = await bloc.stream.firstWhere(
      (state) => state.ownerRequestsMessage == 'Permintaan karyawan disetujui.',
    );

    expect(updated.ownerRequests, isEmpty);
    expect(repository.decisions, ['request-1:true']);
    await bloc.close();
  });

  test(
    'managed employee pagination merges without duplicate employees',
    () async {
      final repository = _PagedEmployeeRepository();
      final bloc = EmployeeBloc(repository);
      bloc.add(const ManagedEmployeesRequested());
      await bloc.stream.firstWhere(
        (state) => state.listStatus == EmployeeListStatus.ready,
      );

      bloc.add(const ManagedEmployeesLoadMoreRequested());
      final loaded = await bloc.stream.firstWhere(
        (state) =>
            state.listStatus == EmployeeListStatus.ready &&
            state.employeePagination?.page == 2,
      );

      expect(repository.requestedPages, [1, 2]);
      expect(loaded.managedEmployees.map((employee) => employee.id), [
        'employee-1',
        'employee-2',
      ]);
      await bloc.close();
    },
  );

  test(
    'managed employee updates synchronize the list and selected detail',
    () async {
      final bloc = EmployeeBloc(_PagedEmployeeRepository());
      bloc.add(const ManagedEmployeesRequested());
      await bloc.stream.firstWhere(
        (state) => state.listStatus == EmployeeListStatus.ready,
      );
      bloc.add(const ManagedEmployeeDetailRequested('employee-1'));
      await bloc.stream.firstWhere(
        (state) => state.selectedEmployee?.id == 'employee-1',
      );

      bloc.add(
        const ManagedEmployeePositionUpdateRequested(
          employeeId: 'employee-1',
          position: 'Supervisor',
        ),
      );
      final updated = await bloc.stream.firstWhere(
        (state) => state.message == 'Informasi pekerjaan diperbarui.',
      );

      expect(updated.selectedEmployee?.position, 'Supervisor');
      expect(
        updated.managedEmployees
            .firstWhere((employee) => employee.id == 'employee-1')
            .position,
        'Supervisor',
      );
      await bloc.close();
    },
  );

  test(
    'status changes remove employee from the active filter results',
    () async {
      final bloc = EmployeeBloc(_PagedEmployeeRepository());
      bloc.add(
        const ManagedEmployeesRequested(
          status: EmployeeEmploymentStatus.active,
        ),
      );
      await bloc.stream.firstWhere(
        (state) => state.listStatus == EmployeeListStatus.ready,
      );

      bloc.add(
        const ManagedEmployeeStatusUpdateRequested(
          employeeId: 'employee-1',
          status: EmployeeEmploymentStatus.inactive,
        ),
      );
      final updated = await bloc.stream.firstWhere(
        (state) => state.message == 'Status karyawan diperbarui.',
      );

      expect(
        updated.selectedEmployee?.status,
        EmployeeEmploymentStatus.inactive,
      );
      expect(updated.managedEmployees, isEmpty);
      expect(updated.employeePagination?.total, 1);
      await bloc.close();
    },
  );

  test('profile update preserves the authenticated session', () async {
    final bloc = AuthBloc(_FakeProfileAuthRepository());
    bloc.add(const SessionRestoreRequested());
    await bloc.stream.firstWhere(
      (state) => state.status == AuthStatus.authenticated,
    );

    final states = bloc.stream.take(2).toList();
    bloc.add(const ProfileUpdateRequested(name: 'Ayu Baru', phone: null));
    final emitted = await states;

    expect(emitted.map((state) => state.status), [
      AuthStatus.loading,
      AuthStatus.authenticated,
    ]);
    expect(emitted.last.user?.name, 'Ayu Baru');
    expect(emitted.last.user?.email, 'ayu@example.com');
    expect(emitted.last.membershipAccess, MembershipAccess.none);
    await bloc.close();
  });

  test('organization load reports repository failures', () async {
    final bloc = OrganizationBloc(_FailingOrganizationRepository());
    final states = bloc.stream.take(2).toList();

    bloc.add(const OrganizationLoadRequested('organization-1'));
    final emitted = await states;

    expect(emitted.map((state) => state.status), [
      OrganizationStatus.loading,
      OrganizationStatus.failure,
    ]);
    expect(emitted.last.message, 'Informasi tidak tersedia.');
    await bloc.close();
  });
}

class _FakeProfileAuthRepository extends AuthRepository {
  _FakeProfileAuthRepository() : super(client: Dio());

  @override
  Future<RestoredSession?> restoreSession() async => RestoredSession(
    user: const UserEntity(id: 'user-1', name: 'Ayu', email: 'ayu@example.com'),
    memberships: const [],
    access: MembershipAccess.none,
  );

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String? phone,
    required String? photoProfile,
  }) async => UserEntity(
    id: 'user-1',
    name: name,
    email: 'ayu@example.com',
    phone: phone,
    photoProfile: photoProfile,
  );
}

class _PagedEmployeeRepository extends EmployeeRepository {
  _PagedEmployeeRepository() : super(client: Dio());

  final requestedPages = <int>[];

  EmployeeEntity _employee({
    required String id,
    String? position,
    EmployeeEmploymentStatus status = EmployeeEmploymentStatus.active,
  }) => EmployeeEntity(id: id, name: id, position: position, status: status);

  @override
  Future<({List<EmployeeEntity> employees, EmployeePagination pagination})>
  getManagedEmployees({
    required int page,
    required int limit,
    String? search,
    EmployeeEmploymentStatus? status,
  }) async {
    requestedPages.add(page);
    return (
      employees: page == 1
          ? [_employee(id: 'employee-1')]
          : [_employee(id: 'employee-1'), _employee(id: 'employee-2')],
      pagination: EmployeePagination(
        page: page,
        limit: limit,
        total: 2,
        totalPages: 2,
      ),
    );
  }

  @override
  Future<EmployeeEntity> getManagedEmployee(String employeeId) async =>
      _employee(id: employeeId);

  @override
  Future<EmployeeEntity> updateManagedEmployee({
    required String employeeId,
    required String? position,
  }) async => _employee(id: employeeId, position: position);

  @override
  Future<EmployeeEntity> updateManagedEmployeeStatus({
    required String employeeId,
    required EmployeeEmploymentStatus status,
  }) async => _employee(id: employeeId, status: status);
}

class _FakeInvitationRepository extends InvitationRepository {
  _FakeInvitationRepository() : super(client: Dio());

  final decisions = <String>[];
  List<JoinRequestEntity> requests = const [
    JoinRequestEntity(id: 'request-1', status: JoinRequestStatus.pending),
  ];

  @override
  Future<List<JoinRequestEntity>> getOwnerRequests(
    String organizationId,
  ) async => requests;

  @override
  Future<void> decideOwnerRequest({
    required String organizationId,
    required String requestId,
    required bool approve,
  }) async {
    decisions.add('$requestId:$approve');
    requests = requests.where((request) => request.id != requestId).toList();
  }
}

class _FailingOrganizationRepository extends OrganizationRepository {
  _FailingOrganizationRepository() : super(client: Dio());

  @override
  Future<OrganizationEntity> getOrganization(String organizationId) async {
    throw const ApiFailure('Informasi tidak tersedia.');
  }
}

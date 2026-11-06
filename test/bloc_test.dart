import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';
import 'package:frontend/modules/auth/data/auth_repository.dart';
import 'package:frontend/modules/auth/domain/entities/user_entity.dart';
import 'package:frontend/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/modules/employees/data/employee_repository.dart';
import 'package:frontend/modules/employees/domain/entities/join_request_entity.dart';
import 'package:frontend/modules/employees/domain/entities/membership_entity.dart';
import 'package:frontend/modules/employees/presentation/bloc/employee_bloc.dart';
import 'package:frontend/modules/organization/data/organization_repository.dart';
import 'package:frontend/modules/organization/domain/entities/organization_entity.dart';
import 'package:frontend/modules/organization/presentation/bloc/organization_bloc.dart';

void main() {
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

  test('employee load emits loading then empty-ready data', () async {
    final bloc = EmployeeBloc(_FakeEmployeeRepository());
    final states = bloc.stream.take(2).toList();

    bloc.add(const EmployeeDataRequested('organization-1'));
    final emitted = await states;

    expect(emitted.map((state) => state.status), [
      EmployeeStatus.loading,
      EmployeeStatus.ready,
    ]);
    expect(emitted.last.members, isEmpty);
    expect(emitted.last.pendingRequests, isEmpty);
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

class _FakeEmployeeRepository extends EmployeeRepository {
  _FakeEmployeeRepository() : super(client: Dio());

  @override
  Future<List<MembershipEntity>> getMembers(String organizationId) async => [];

  @override
  Future<List<JoinRequestEntity>> getPendingRequests(
    String organizationId,
  ) async => [];
}

class _FailingOrganizationRepository extends OrganizationRepository {
  _FailingOrganizationRepository() : super(client: Dio());

  @override
  Future<OrganizationEntity> getOrganization(String organizationId) async {
    throw const ApiFailure('Informasi tidak tersedia.');
  }
}

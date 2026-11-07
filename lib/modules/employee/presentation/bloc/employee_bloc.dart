import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/employee_repository.dart';
import 'employee_event.dart';
import 'employee_state.dart';

export 'employee_event.dart';
export 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc(this._repository) : super(const EmployeeState()) {
    on<EmployeeStateResetRequested>((event, emit) {
      emit(const EmployeeState());
    });
    on<EmployeeDataRequested>(_load);
    on<EmployeeDetailRequested>(_loadDetail);
    on<EmployeeInvitationRequested>(_invite);
    on<EmployeeInvitationRevocationRequested>(_revokeInvitation);
    on<JoinRequestDecisionRequested>(_decide);
  }

  final EmployeeRepository _repository;

  Future<void> _load(
    EmployeeDataRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.loading) return;
    emit(state.copyWith(status: EmployeeStatus.loading, message: null));
    try {
      final membersFuture = _repository.getMembers(event.organizationId);
      final requestsFuture = _repository.getPendingRequests(
        event.organizationId,
      );
      await Future.wait<Object>([membersFuture, requestsFuture]);
      emit(
        state.copyWith(
          status: EmployeeStatus.ready,
          members: await membersFuture,
          pendingRequests: await requestsFuture,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  Future<void> _loadDetail(
    EmployeeDetailRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatus.loading, message: null));
    try {
      final member = await _repository.getMember(
        event.organizationId,
        event.membershipId,
      );
      emit(
        state.copyWith(status: EmployeeStatus.ready, selectedMember: member),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  Future<void> _invite(
    EmployeeInvitationRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.mutating) return;
    emit(state.copyWith(status: EmployeeStatus.mutating, message: null));
    try {
      final invitation = await _repository.createInvitation(
        organizationId: event.organizationId,
        email: event.email,
      );
      emit(
        state.copyWith(
          status: EmployeeStatus.ready,
          invitation: invitation,
          message: 'Undangan berhasil dibuat. Bagikan token kepada karyawan.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  Future<void> _decide(
    JoinRequestDecisionRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.mutating) return;
    emit(state.copyWith(status: EmployeeStatus.mutating, message: null));
    try {
      await _repository.decideRequest(
        organizationId: event.organizationId,
        requestId: event.requestId,
        approve: event.approve,
      );
      final requests = await _repository.getPendingRequests(
        event.organizationId,
      );
      final members = event.approve
          ? await _repository.getMembers(event.organizationId)
          : state.members;
      emit(
        state.copyWith(
          status: EmployeeStatus.ready,
          pendingRequests: requests,
          members: members,
          message: event.approve
              ? 'Permintaan karyawan disetujui.'
              : 'Permintaan karyawan ditolak.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }

  Future<void> _revokeInvitation(
    EmployeeInvitationRevocationRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status == EmployeeStatus.mutating) return;
    emit(state.copyWith(status: EmployeeStatus.mutating, message: null));
    try {
      await _repository.revokeInvitation(
        organizationId: event.organizationId,
        invitationId: event.invitationId,
      );
      emit(
        state.copyWith(
          status: EmployeeStatus.ready,
          clearInvitation: true,
          message: 'Undangan berhasil dicabut.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(status: EmployeeStatus.failure, message: error.message),
      );
    }
  }
}

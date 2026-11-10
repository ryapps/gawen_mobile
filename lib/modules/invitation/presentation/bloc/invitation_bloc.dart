import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/invitation_repository.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';

export 'invitation_event.dart';
export 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  InvitationBloc(this._repository) : super(const InvitationState()) {
    on<InvitationStateResetRequested>((event, emit) {
      emit(const InvitationState());
    });
    on<RequestsRefreshRequested>(_refresh);
    on<BusinessCodeSubmitted>(_join);
    on<InvitationAccepted>(_accept);
    on<OwnerJoinRequestsRefreshRequested>(_refreshOwnerRequests);
    on<OwnerJoinRequestDecisionRequested>(_decideOwnerRequest);
    on<EmailInvitationCreatedRequested>(_createEmailInvitation);
    on<EmailInvitationRevokedRequested>(_revokeEmailInvitation);
    on<OwnInvitationsRefreshRequested>(_refreshOwnInvitations);
    on<EmployeeInvitationAccepted>(_acceptEmployeeInvitation);
  }

  final InvitationRepository _repository;

  Future<void> _refresh(
    RequestsRefreshRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.status == InvitationStatus.loading) return;
    emit(state.copyWith(status: InvitationStatus.loading, message: null));
    try {
      final requests = await _repository.getOwnRequests();
      emit(state.copyWith(status: InvitationStatus.ready, requests: requests));
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _join(
    BusinessCodeSubmitted event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.status == InvitationStatus.loading) return;
    emit(state.copyWith(status: InvitationStatus.loading, message: null));
    try {
      final message = await _repository.requestMembership(event.businessCode);
      emit(
        state.copyWith(status: InvitationStatus.submitted, message: message),
      );
      add(const RequestsRefreshRequested());
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _accept(
    InvitationAccepted event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.status == InvitationStatus.loading) return;
    emit(state.copyWith(status: InvitationStatus.loading, message: null));
    try {
      await _repository.acceptInvitation(event.token);
      emit(
        state.copyWith(
          status: InvitationStatus.accepted,
          message: 'Undangan berhasil diterima.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          status: InvitationStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _refreshOwnerRequests(
    OwnerJoinRequestsRefreshRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.ownerRequestsStatus == OwnerJoinRequestsStatus.loading) return;
    emit(
      state.copyWith(
        ownerRequestsStatus: OwnerJoinRequestsStatus.loading,
        ownerRequestsMessage: null,
      ),
    );
    try {
      final requests = await _repository.getOwnerRequests(event.organizationId);
      emit(
        state.copyWith(
          ownerRequestsStatus: OwnerJoinRequestsStatus.ready,
          ownerRequests: requests,
          ownerRequestsMessage: null,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          ownerRequestsStatus: OwnerJoinRequestsStatus.failure,
          ownerRequestsMessage: error.message,
        ),
      );
    }
  }

  Future<void> _decideOwnerRequest(
    OwnerJoinRequestDecisionRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.ownerRequestsStatus == OwnerJoinRequestsStatus.mutating) return;
    emit(
      state.copyWith(
        ownerRequestsStatus: OwnerJoinRequestsStatus.mutating,
        ownerRequestsMessage: null,
      ),
    );
    try {
      await _repository.decideOwnerRequest(
        organizationId: event.organizationId,
        requestId: event.requestId,
        approve: event.approve,
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          ownerRequestsStatus: OwnerJoinRequestsStatus.failure,
          ownerRequestsMessage: error.message,
        ),
      );
      return;
    }

    final locallyUpdatedRequests = state.ownerRequests
        .where((request) => request.id != event.requestId)
        .toList(growable: false);
    try {
      final requests = await _repository.getOwnerRequests(event.organizationId);
      emit(
        state.copyWith(
          ownerRequestsStatus: OwnerJoinRequestsStatus.ready,
          ownerRequests: requests,
          ownerRequestsMessage: event.approve
              ? 'Permintaan karyawan disetujui.'
              : 'Permintaan karyawan ditolak.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          ownerRequestsStatus: OwnerJoinRequestsStatus.failure,
          ownerRequests: locallyUpdatedRequests,
          ownerRequestsMessage:
              '${event.approve ? 'Permintaan karyawan disetujui' : 'Permintaan karyawan ditolak'}, tetapi daftar gagal diperbarui: ${error.message}',
        ),
      );
    }
  }

  Future<void> _createEmailInvitation(
    EmailInvitationCreatedRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.emailInvitationStatus == EmailInvitationStatus.mutating) return;
    emit(
      state.copyWith(
        emailInvitationStatus: EmailInvitationStatus.mutating,
        emailInvitationMessage: null,
      ),
    );
    try {
      final invitation = await _repository.createEmailInvitation(
        organizationId: event.organizationId,
        email: event.email,
      );
      emit(
        state.copyWith(
          emailInvitationStatus: EmailInvitationStatus.ready,
          createdInvitation: invitation,
          emailInvitationMessage:
              'Undangan tersedia di akun karyawan yang dipilih.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          emailInvitationStatus: EmailInvitationStatus.failure,
          emailInvitationMessage: error.message,
        ),
      );
    }
  }

  Future<void> _refreshOwnInvitations(
    OwnInvitationsRefreshRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.invitationInboxStatus == InvitationInboxStatus.loading) return;
    emit(
      state.copyWith(
        invitationInboxStatus: InvitationInboxStatus.loading,
        invitationInboxMessage: null,
      ),
    );
    try {
      final invitations = await _repository.getOwnInvitations();
      emit(
        state.copyWith(
          invitationInboxStatus: InvitationInboxStatus.ready,
          ownInvitations: invitations,
          invitationInboxMessage: null,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          invitationInboxStatus: InvitationInboxStatus.failure,
          invitationInboxMessage: error.message,
        ),
      );
    }
  }

  Future<void> _acceptEmployeeInvitation(
    EmployeeInvitationAccepted event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.invitationInboxStatus == InvitationInboxStatus.mutating) return;
    emit(
      state.copyWith(
        invitationInboxStatus: InvitationInboxStatus.mutating,
        invitationInboxMessage: null,
      ),
    );
    try {
      await _repository.acceptInvitationById(event.invitationId);
      emit(
        state.copyWith(
          invitationInboxStatus: InvitationInboxStatus.accepted,
          ownInvitations: state.ownInvitations
              .where((invitation) => invitation.id != event.invitationId)
              .toList(growable: false),
          invitationInboxMessage: 'Undangan berhasil diterima.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          invitationInboxStatus: InvitationInboxStatus.failure,
          invitationInboxMessage: error.message,
        ),
      );
    }
  }

  Future<void> _revokeEmailInvitation(
    EmailInvitationRevokedRequested event,
    Emitter<InvitationState> emit,
  ) async {
    if (state.emailInvitationStatus == EmailInvitationStatus.mutating) return;
    emit(
      state.copyWith(
        emailInvitationStatus: EmailInvitationStatus.mutating,
        emailInvitationMessage: null,
      ),
    );
    try {
      await _repository.revokeEmailInvitation(
        organizationId: event.organizationId,
        invitationId: event.invitationId,
      );
      emit(
        state.copyWith(
          emailInvitationStatus: EmailInvitationStatus.ready,
          clearCreatedInvitation: true,
          emailInvitationMessage: 'Undangan berhasil dicabut.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          emailInvitationStatus: EmailInvitationStatus.failure,
          emailInvitationMessage: error.message,
        ),
      );
    }
  }
}

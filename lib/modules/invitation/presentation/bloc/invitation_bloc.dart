import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/invitation_repository.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';

export 'invitation_event.dart';
export 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  InvitationBloc(this._repository) : super(const InvitationState()) {
    on<RequestsRefreshRequested>(_refresh);
    on<BusinessCodeSubmitted>(_join);
    on<InvitationAccepted>(_accept);
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
}

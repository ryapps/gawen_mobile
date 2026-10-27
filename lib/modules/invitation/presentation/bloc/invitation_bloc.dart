import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/invitation_repository.dart';

enum InvitationStatus { initial, loading, ready, submitted, accepted, failure }

class InvitationState {
  const InvitationState({
    this.status = InvitationStatus.initial,
    this.requests = const [],
    this.message,
  });

  final InvitationStatus status;
  final List<Map<String, dynamic>> requests;
  final String? message;

  InvitationState copyWith({
    InvitationStatus? status,
    List<Map<String, dynamic>>? requests,
    String? message,
  }) => InvitationState(
    status: status ?? this.status,
    requests: requests ?? this.requests,
    message: message,
  );
}

sealed class InvitationEvent {
  const InvitationEvent();
}

final class RequestsRefreshRequested extends InvitationEvent {
  const RequestsRefreshRequested();
}

final class BusinessCodeSubmitted extends InvitationEvent {
  const BusinessCodeSubmitted(this.businessCode);

  final String businessCode;
}

final class InvitationAccepted extends InvitationEvent {
  const InvitationAccepted(this.token);

  final String token;
}

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

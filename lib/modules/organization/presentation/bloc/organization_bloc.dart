import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/organization_repository.dart';
import 'organization_event.dart';
import 'organization_state.dart';

export 'organization_event.dart';
export 'organization_state.dart';

class OrganizationBloc extends Bloc<OrganizationEvent, OrganizationState> {
  OrganizationBloc(this._repository) : super(const OrganizationState()) {
    on<OrganizationStateResetRequested>((event, emit) {
      emit(const OrganizationState());
    });
    on<OrganizationLoadRequested>(_load);
    on<OrganizationUpdateRequested>(_update);
  }

  final OrganizationRepository _repository;

  Future<void> _load(
    OrganizationLoadRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    if (state.status == OrganizationStatus.loading) return;
    emit(state.copyWith(status: OrganizationStatus.loading, message: null));
    try {
      final organization = await _repository.getOrganization(
        event.organizationId,
      );
      emit(
        state.copyWith(
          status: OrganizationStatus.ready,
          organization: organization,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          status: OrganizationStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _update(
    OrganizationUpdateRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    if (state.status == OrganizationStatus.saving) return;
    emit(state.copyWith(status: OrganizationStatus.saving, message: null));
    try {
      final organization = await _repository.updateOrganization(
        organizationId: event.organizationId,
        name: event.name,
        timezone: event.timezone,
      );
      emit(
        state.copyWith(
          status: OrganizationStatus.ready,
          organization: organization,
          message: 'Informasi usaha berhasil disimpan.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          status: OrganizationStatus.failure,
          message: error.message,
        ),
      );
    }
  }
}

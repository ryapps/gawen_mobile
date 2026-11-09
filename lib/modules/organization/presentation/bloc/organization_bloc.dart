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
    on<BusinessJoinCodeRequested>(_loadBusinessJoinCode);
    on<BusinessJoinCodeRotationRequested>(_rotateBusinessJoinCode);
    on<OrganizationUpdateRequested>(_update);
    on<OrganizationLogoUploadRequested>(_uploadLogo);
    on<OrganizationSetupCompletionRequested>(_completeSetup);
    on<OrganizationSetupStepSaveRequested>(_saveSetupStep);
  }

  final OrganizationRepository _repository;

  Future<void> _loadBusinessJoinCode(
    BusinessJoinCodeRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(
      state.copyWith(
        businessJoinCodeStatus: BusinessJoinCodeStatus.loading,
        businessJoinCodeOrganizationId: event.organizationId,
        businessJoinCodeMessage: null,
        clearBusinessJoinCode: true,
      ),
    );
    try {
      final code = await _repository.getSavedBusinessJoinCode(
        event.organizationId,
      );
      emit(
        state.copyWith(
          businessJoinCodeStatus: BusinessJoinCodeStatus.ready,
          businessJoinCode: code,
          businessJoinCodeOrganizationId: event.organizationId,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          businessJoinCodeStatus: BusinessJoinCodeStatus.failure,
          businessJoinCodeMessage: error.message,
        ),
      );
    }
  }

  Future<void> _rotateBusinessJoinCode(
    BusinessJoinCodeRotationRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    if (state.businessJoinCodeStatus == BusinessJoinCodeStatus.rotating) return;
    emit(
      state.copyWith(
        businessJoinCodeStatus: BusinessJoinCodeStatus.rotating,
        businessJoinCodeOrganizationId: event.organizationId,
        businessJoinCodeMessage: null,
      ),
    );
    try {
      final result = await _repository.rotateBusinessJoinCode(
        event.organizationId,
      );
      emit(
        state.copyWith(
          businessJoinCodeStatus: BusinessJoinCodeStatus.ready,
          businessJoinCode: result.code,
          businessJoinCodeOrganizationId: event.organizationId,
          businessJoinCodeMessage: result.stored
              ? 'Kode bergabung berhasil diperbarui.'
              : 'Kode berhasil dibuat. Salin sekarang karena perangkat tidak dapat menyimpannya.',
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          businessJoinCodeStatus: BusinessJoinCodeStatus.failure,
          businessJoinCodeMessage: error.message,
        ),
      );
    }
  }

  Future<void> _uploadLogo(
    OrganizationLogoUploadRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(state.copyWith(status: OrganizationStatus.saving, message: null));
    try {
      final organization = await _repository.uploadLogo(
        organizationId: event.organizationId,
        filePath: event.filePath,
      );
      emit(
        state.copyWith(
          status: OrganizationStatus.ready,
          organization: organization,
          message: 'Logo usaha berhasil diunggah.',
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
        businessType: event.businessType,
        description: event.description,
        logoUrl: event.logoUrl,
        email: event.email,
        phone: event.phone,
        website: event.website,
        address: event.address,
        city: event.city,
        province: event.province,
        postalCode: event.postalCode,
        currency: event.currency,
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

  Future<void> _completeSetup(
    OrganizationSetupCompletionRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(state.copyWith(status: OrganizationStatus.saving, message: null));
    try {
      final organization = await _repository.completeSetup(
        event.organizationId,
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

  Future<void> _saveSetupStep(
    OrganizationSetupStepSaveRequested event,
    Emitter<OrganizationState> emit,
  ) async {
    emit(state.copyWith(status: OrganizationStatus.saving, message: null));
    try {
      final organization = await _repository.saveSetupStep(
        organizationId: event.organizationId,
        step: event.step,
        fields: event.fields,
      );
      emit(
        state.copyWith(
          status: OrganizationStatus.ready,
          organization: organization,
          message: 'Progres berhasil disimpan.',
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

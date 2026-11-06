import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_failure.dart';
import '../../data/region_repository.dart';
import 'region_event.dart';
import 'region_state.dart';

export 'region_event.dart';
export 'region_state.dart';

class RegionBloc extends Bloc<RegionEvent, RegionState> {
  RegionBloc(this._repository) : super(const RegionState()) {
    on<ProvincesRequested>(_loadProvinces);
    on<RegenciesRequested>(_loadRegencies);
    on<DistrictsRequested>(_loadDistricts);
    on<VillagesRequested>(_loadVillages);
  }

  final RegionRepository _repository;

  Future<void> _loadProvinces(
    ProvincesRequested event,
    Emitter<RegionState> emit,
  ) async {
    emit(
      state.copyWith(
        provincesStatus: RegionLoadStatus.loading,
        clearProvincesError: true,
      ),
    );
    try {
      emit(
        state.copyWith(
          provinces: await _repository.getProvinces(),
          provincesStatus: RegionLoadStatus.success,
        ),
      );
    } on ApiFailure catch (error) {
      emit(
        state.copyWith(
          provincesStatus: RegionLoadStatus.failure,
          provincesError: error.message,
        ),
      );
    }
  }

  Future<void> _loadRegencies(
    RegenciesRequested event,
    Emitter<RegionState> emit,
  ) async {
    emit(
      state.copyWith(
        regencies: const [],
        districts: const [],
        villages: const [],
        regenciesStatus: RegionLoadStatus.loading,
        districtsStatus: RegionLoadStatus.initial,
        villagesStatus: RegionLoadStatus.initial,
        regenciesProvinceCode: event.provinceCode,
        clearDistrictsRegencyCode: true,
        clearVillagesDistrictCode: true,
        clearRegenciesError: true,
        clearDistrictsError: true,
        clearVillagesError: true,
      ),
    );
    try {
      final regencies = await _repository.getRegencies(event.provinceCode);
      if (state.regenciesProvinceCode != event.provinceCode) return;
      emit(
        state.copyWith(
          regencies: regencies,
          regenciesStatus: RegionLoadStatus.success,
        ),
      );
    } on ApiFailure catch (error) {
      if (state.regenciesProvinceCode != event.provinceCode) return;
      emit(
        state.copyWith(
          regenciesStatus: RegionLoadStatus.failure,
          regenciesError: error.message,
        ),
      );
    }
  }

  Future<void> _loadDistricts(
    DistrictsRequested event,
    Emitter<RegionState> emit,
  ) async {
    emit(
      state.copyWith(
        districts: const [],
        villages: const [],
        districtsStatus: RegionLoadStatus.loading,
        villagesStatus: RegionLoadStatus.initial,
        districtsRegencyCode: event.regencyCode,
        clearVillagesDistrictCode: true,
        clearDistrictsError: true,
        clearVillagesError: true,
      ),
    );
    try {
      final districts = await _repository.getDistricts(event.regencyCode);
      if (state.districtsRegencyCode != event.regencyCode) return;
      emit(
        state.copyWith(
          districts: districts,
          districtsStatus: RegionLoadStatus.success,
        ),
      );
    } on ApiFailure catch (error) {
      if (state.districtsRegencyCode != event.regencyCode) return;
      emit(
        state.copyWith(
          districtsStatus: RegionLoadStatus.failure,
          districtsError: error.message,
        ),
      );
    }
  }

  Future<void> _loadVillages(
    VillagesRequested event,
    Emitter<RegionState> emit,
  ) async {
    emit(
      state.copyWith(
        villages: const [],
        villagesStatus: RegionLoadStatus.loading,
        villagesDistrictCode: event.districtCode,
        clearVillagesError: true,
      ),
    );
    try {
      final villages = await _repository.getVillages(event.districtCode);
      if (state.villagesDistrictCode != event.districtCode) return;
      emit(
        state.copyWith(
          villages: villages,
          villagesStatus: RegionLoadStatus.success,
        ),
      );
    } on ApiFailure catch (error) {
      if (state.villagesDistrictCode != event.districtCode) return;
      emit(
        state.copyWith(
          villagesStatus: RegionLoadStatus.failure,
          villagesError: error.message,
        ),
      );
    }
  }
}

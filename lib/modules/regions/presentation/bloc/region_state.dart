import '../../domain/entities/administrative_region.dart';

enum RegionLoadStatus { initial, loading, success, failure }

class RegionState {
  const RegionState({
    this.provinces = const [],
    this.regencies = const [],
    this.districts = const [],
    this.villages = const [],
    this.provincesStatus = RegionLoadStatus.initial,
    this.regenciesStatus = RegionLoadStatus.initial,
    this.districtsStatus = RegionLoadStatus.initial,
    this.villagesStatus = RegionLoadStatus.initial,
    this.regenciesProvinceCode,
    this.districtsRegencyCode,
    this.villagesDistrictCode,
    this.provincesError,
    this.regenciesError,
    this.districtsError,
    this.villagesError,
  });

  final List<AdministrativeRegion> provinces;
  final List<AdministrativeRegion> regencies;
  final List<AdministrativeRegion> districts;
  final List<AdministrativeRegion> villages;
  final RegionLoadStatus provincesStatus;
  final RegionLoadStatus regenciesStatus;
  final RegionLoadStatus districtsStatus;
  final RegionLoadStatus villagesStatus;
  final String? regenciesProvinceCode;
  final String? districtsRegencyCode;
  final String? villagesDistrictCode;
  final String? provincesError;
  final String? regenciesError;
  final String? districtsError;
  final String? villagesError;

  RegionState copyWith({
    List<AdministrativeRegion>? provinces,
    List<AdministrativeRegion>? regencies,
    List<AdministrativeRegion>? districts,
    List<AdministrativeRegion>? villages,
    RegionLoadStatus? provincesStatus,
    RegionLoadStatus? regenciesStatus,
    RegionLoadStatus? districtsStatus,
    RegionLoadStatus? villagesStatus,
    String? regenciesProvinceCode,
    String? districtsRegencyCode,
    String? villagesDistrictCode,
    String? provincesError,
    String? regenciesError,
    String? districtsError,
    String? villagesError,
    bool clearProvincesError = false,
    bool clearRegenciesError = false,
    bool clearDistrictsError = false,
    bool clearVillagesError = false,
    bool clearDistrictsRegencyCode = false,
    bool clearVillagesDistrictCode = false,
  }) => RegionState(
    provinces: provinces ?? this.provinces,
    regencies: regencies ?? this.regencies,
    districts: districts ?? this.districts,
    villages: villages ?? this.villages,
    provincesStatus: provincesStatus ?? this.provincesStatus,
    regenciesStatus: regenciesStatus ?? this.regenciesStatus,
    districtsStatus: districtsStatus ?? this.districtsStatus,
    villagesStatus: villagesStatus ?? this.villagesStatus,
    regenciesProvinceCode: regenciesProvinceCode ?? this.regenciesProvinceCode,
    districtsRegencyCode: clearDistrictsRegencyCode
        ? null
        : districtsRegencyCode ?? this.districtsRegencyCode,
    villagesDistrictCode: clearVillagesDistrictCode
        ? null
        : villagesDistrictCode ?? this.villagesDistrictCode,
    provincesError: clearProvincesError
        ? null
        : provincesError ?? this.provincesError,
    regenciesError: clearRegenciesError
        ? null
        : regenciesError ?? this.regenciesError,
    districtsError: clearDistrictsError
        ? null
        : districtsError ?? this.districtsError,
    villagesError: clearVillagesError
        ? null
        : villagesError ?? this.villagesError,
  );
}

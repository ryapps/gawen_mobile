import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_failure.dart';
import 'package:frontend/modules/regions/data/region_repository.dart';
import 'package:frontend/modules/regions/domain/entities/administrative_region.dart';
import 'package:frontend/modules/regions/presentation/bloc/region_bloc.dart';

void main() {
  test('region bloc loads each level for its selected parent', () async {
    final repository = _FakeRegionRepository();
    final bloc = RegionBloc(repository);

    final provincesReady = bloc.stream.firstWhere(
      (state) => state.provincesStatus == RegionLoadStatus.success,
    );
    bloc.add(const ProvincesRequested());
    await provincesReady;

    final regenciesReady = bloc.stream.firstWhere(
      (state) => state.regenciesStatus == RegionLoadStatus.success,
    );
    bloc.add(const RegenciesRequested('31'));
    await regenciesReady;

    final districtsReady = bloc.stream.firstWhere(
      (state) => state.districtsStatus == RegionLoadStatus.success,
    );
    bloc.add(const DistrictsRequested('31.74'));
    await districtsReady;

    final villagesReady = bloc.stream.firstWhere(
      (state) => state.villagesStatus == RegionLoadStatus.success,
    );
    bloc.add(const VillagesRequested('31.74.07'));
    final loaded = await villagesReady;

    expect(repository.requestedParents, [
      'province',
      '31',
      '31.74',
      '31.74.07',
    ]);
    expect(loaded.villages.single.id, '31.74.07.1002');
    await bloc.close();
  });

  test('region bloc exposes loading errors for retry UI', () async {
    final bloc = RegionBloc(_FailingRegionRepository());
    final failed = bloc.stream.firstWhere(
      (state) => state.provincesStatus == RegionLoadStatus.failure,
    );

    bloc.add(const ProvincesRequested());
    final state = await failed;

    expect(state.provincesError, 'Data wilayah tidak tersedia.');
    await bloc.close();
  });
}

class _FakeRegionRepository extends RegionRepository {
  _FakeRegionRepository() : super(client: Dio());

  final requestedParents = <String>[];

  @override
  Future<List<AdministrativeRegion>> getProvinces() async {
    requestedParents.add('province');
    return const [AdministrativeRegion(id: '31', name: 'DKI Jakarta')];
  }

  @override
  Future<List<AdministrativeRegion>> getRegencies(String provinceCode) async {
    requestedParents.add(provinceCode);
    return const [
      AdministrativeRegion(id: '31.74', name: 'Kota Jakarta Selatan'),
    ];
  }

  @override
  Future<List<AdministrativeRegion>> getDistricts(String regencyCode) async {
    requestedParents.add(regencyCode);
    return const [AdministrativeRegion(id: '31.74.07', name: 'Kebayoran Baru')];
  }

  @override
  Future<List<AdministrativeRegion>> getVillages(String districtCode) async {
    requestedParents.add(districtCode);
    return const [AdministrativeRegion(id: '31.74.07.1002', name: 'Gunung')];
  }
}

class _FailingRegionRepository extends RegionRepository {
  _FailingRegionRepository() : super(client: Dio());

  @override
  Future<List<AdministrativeRegion>> getProvinces() async {
    throw const ApiFailure('Data wilayah tidak tersedia.');
  }
}
